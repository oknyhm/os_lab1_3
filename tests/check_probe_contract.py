#!/usr/bin/env python3
"""Supplemental checks; --self-test uses fixtures, not live VM evidence."""
import argparse
import datetime
import errno
import os
from pathlib import Path
import platform
import subprocess
import sys
import time
import unittest

EXPECTED = "6.12.110-oslab3-xxx"
PROC = Path("/proc/oslab3_boot")


def validate_samples(first, second, kernel):
    def parse(text):
        fields = {}
        for line in text.splitlines():
            key, value = line.split("=", 1)
            if key in fields:
                raise ValueError("duplicate field: " + key)
            fields[key] = value
        for key in ("kernel", "status", "module_load_boottime_ms", "current_boottime_ms"):
            if key not in fields:
                raise ValueError("missing field: " + key)
        for key in ("module_load_boottime_ms", "current_boottime_ms"):
            if not fields[key].isascii() or not fields[key].isdigit():
                raise ValueError("invalid time: " + key)
            fields[key] = int(fields[key])
        return fields
    try:
        a, b = parse(first), parse(second)
    except ValueError as exc:
        return {"E01-fields": (False, str(exc))}
    load = a["module_load_boottime_ms"]
    return {
        "E01-fields": (True, "required fields and numeric timestamps present"),
        "E02-kernel-status": (all(x["kernel"] == kernel == EXPECTED and x["status"] == "ready"
                                  for x in (a, b)), "proc kernel matches uname; status=ready"),
        "E03-time-contract": (load == b["module_load_boottime_ms"] and
                              load <= a["current_boottime_ms"] < b["current_boottime_ms"],
                              "load stable; current time increases and follows load"),
    }


def failed_units_ok(returncode, output):
    return returncode == 0 and not output.strip()


class ContractTests(unittest.TestCase):
    def sample(self, now=101, load=10, kernel=EXPECTED):
        return (f"kernel={kernel}\nstatus=ready\nmodule_load_boottime_ms={load}\n"
                f"current_boottime_ms={now}\n")
    def test_valid(self):
        self.assertTrue(all(v[0] for v in validate_samples(self.sample(), self.sample(102), EXPECTED).values()))
    def test_wrong_kernel(self):
        self.assertFalse(validate_samples(self.sample(kernel="wrong"), self.sample(102), EXPECTED)["E02-kernel-status"][0])
    def test_time_regression(self):
        self.assertFalse(validate_samples(self.sample(), self.sample(100), EXPECTED)["E03-time-contract"][0])
    def test_load_changed(self):
        self.assertFalse(validate_samples(self.sample(), self.sample(102, 11), EXPECTED)["E03-time-contract"][0])
    def test_invalid_fields(self):
        for bad in ("", self.sample() + "kernel=duplicate\n", self.sample(load="oops")):
            with self.subTest(bad=bad):
                self.assertFalse(validate_samples(bad, self.sample(), EXPECTED)["E01-fields"][0])
    def test_failed_query(self):
        self.assertFalse(failed_units_ok(1, ""))
    def test_failed_unit(self):
        self.assertFalse(failed_units_ok(0, "example.service loaded failed failed"))
    def test_empty_success(self):
        self.assertTrue(failed_units_ok(0, "\n"))


def live():
    print("mode=live; checks do not prove automatic loading")
    print("host=" + platform.node())
    print("kernel=" + platform.release())
    print("boot_id=" + Path("/proc/sys/kernel/random/boot_id").read_text().strip())
    first = PROC.read_text()
    time.sleep(0.05)
    second = PROC.read_text()
    print("sample_1:\n" + first + "sample_2:\n" + second)
    checks = validate_samples(first, second, platform.release())
    mode = PROC.stat().st_mode & 0o777
    checks["E04-mode"] = (mode == 0o444, f"mode={mode:o}; expected=444")
    try:
        # No O_TRUNC, and no payload is written even if open succeeds.
        fd = os.open(PROC, os.O_WRONLY)
    except OSError as exc:
        checks["E05-write-open"] = (exc.errno in (errno.EACCES, errno.EPERM, errno.EIO, errno.EROFS),
                                    f"write-open rejected: errno={exc.errno}; uid={os.geteuid()}")
    else:
        os.close(fd)
        checks["E05-write-open"] = (False, "write-open succeeded; no data written")
    result = subprocess.run(["systemctl", "--failed", "--no-legend", "--plain", "--no-pager"],
                            text=True, capture_output=True, timeout=15)
    checks["E06-failed-units"] = (failed_units_ok(result.returncode, result.stdout),
                                  f"returncode={result.returncode}; stdout={result.stdout!r}; stderr={result.stderr!r}")
    for name, (ok, detail) in checks.items():
        print(f"{'PASS' if ok else 'FAIL'} {name}: {detail}")
    failures = sum(not value[0] for value in checks.values())
    print(f"SUMMARY checks={len(checks)} failures={failures}")
    return 1 if failures else 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    print("collected_at=" + datetime.datetime.now(datetime.timezone.utc).isoformat(), flush=True)
    if args.self_test:
        print("mode=fixture-self-test; NOT live VM results", flush=True)
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(ContractTests)
        result = unittest.TextTestRunner(stream=sys.stdout, verbosity=2).run(suite)
        sys.exit(0 if result.wasSuccessful() else 1)
    try:
        sys.exit(live())
    except (OSError, subprocess.SubprocessError, UnicodeError) as exc:
        print(f"FAIL prerequisite: {exc}", file=sys.stderr)
        sys.exit(2)
