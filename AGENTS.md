# Scope

This repository contains OS experiment 3, Linux boot initialization analysis, despite its requested name `os_lab1_3`. Work only on this experiment unless the user expands the scope. Preserve `XXX` in personal-information fields until the user supplies replacements.

# Evidence is part of the deliverable

- Read `README.md`, `docs/test-matrix.md`, and relevant source/log files before changing a claim.
- Historical VM evidence was collected on 2026-09-21. Repository preparation occurred on 2026-10-05. Do not relabel old runs as new tests.
- Keep raw files in `report/logs/` and original evidence screenshots intact. New test runs belong in separate timestamped locations. Never edit output to make a failed test look successful.
- `ai-record/dialogue-excerpts.md` contains selected visible dialogue, not a full platform export. `interaction-summary.md` is an after-the-fact summary. Four personal-title screenshots were included on 2026-10-07, one as a user-approved local pixel-redacted derivative; its credential-bearing original stays local and ignored. See the index for remaining gaps and historical corrections.
- Keep historical tests unchanged. Supplemental check self-tests use fixtures, not the VM; never present them as live kernel results.
- The 2026-10-07 live retest is archived separately in `report/logs/supplemental-vm-20261007.txt`: 9/9 historical checks and 6/6 supplemental checks passed, load time 6370 ms. Keep it distinct from the 2026-09-21 load time 6557 ms and the eight fixture self-tests. Empty service journal output is not evidence of a captured service trace.
- Every supported behavior needs implementation, a test or reproducible command, and an actual result. State untested behavior and limits explicitly. Do not claim student understanding, full test coverage, successful fallback boot, performance improvement, or complete dialogue evidence without evidence.
- The historical nine-check script has known limits described in README. If improving it, retain/version historical evidence and collect new results before claiming the new tests passed.
- Preserve local baseline/debug artifacts even though they are ignored. Do not delete unrelated workspace files.

# Runtime and system changes

- Recorded VM: Kubuntu 24.04.3 LTS, x86_64, VMware NAT, two vCPUs, 4 GiB RAM. Target kernel `6.12.110-oslab3-xxx`; original kernel `6.11.0-26-kfocus`.
- `extra-design/` is a GPL kernel module with a read-only procfs interface and modules-load configuration. It runs when a userspace service loads the module, not as an early built-in kernel initcall.
- Use SSH as a normal user and sudo only for the required operation. Do not store passwords, private keys, full authorized_keys, tokens, or authentication configuration in repository artifacts.
- Preserve the original kernel and GRUB entries. Do not create snapshots, change passwords, expose SSH publicly, or change unrelated VM services without a new user request.
- Do not rerun the historical fstab repair automatically. It is specific to the diagnosed stale libvirt mounts and requires current read-only checks plus a backup.
- A report/documentation change normally needs no VM reboot or module reinstallation. Runtime changes require proportionate testing and a clear account of new results.

# Files, build, and verification

- Keep source in `extra-design/`, tests in `tests/`, historical automation in `report/scripts/`, evidence in `report/logs/` and `report/figures/`, documentation in `docs/` and `ai-record/`.
- Edit local files with `apply_patch`. Keep shell/code in UTF-8 and LF; the Makefile requires tabs. Use `bash -n` on changed shell scripts.
- Probe build: `cd extra-design && make`, using the exact running kernel's completed build tree. Installation: `bash install-probe.sh`. Run `tests/test_boot_probe.sh` after a real reboot before asserting automatic loading.
- For runtime validation record the kernel, collection time, real command exit status, output and failures. A screenshot alone is not a replacement for the test code.
- Report build: from `report/`, run `xelatex -interaction=nonstopmode -halt-on-error main.tex` twice. Check undefined references and overflow. Render the final PDF with `pdftoppm` and inspect affected pages; check the PDF with `qpdf --check` when available.
- Publish only `output/pdf/实验三_Linux启动初始化过程探析_XXX.pdf` as the report PDF. Do not track auxiliary TeX files or duplicate drafts. TeX fonts must be referenced portably, without host-specific drive paths.
- Update `docs/test-matrix.md`, README, report, and dialogue evidence status together. Regenerate `docs/evidence-sha256.txt` after changing a listed artifact. This manifest records integrity, not authenticity or a digital signature.

# Git and publication

- The user authorized a public GitHub repository named `os_lab1_3`. Limit uploads to the established report/source/tests/evidence/documentation files.
- Do not upload full Linux sources, VM disk images, binaries, teacher-provided PDFs, private authentication material, or unrelated data. Inspect the explicit staged file list before committing.
- Do not fabricate earlier commits, dates or student contributions. Never force-push, rewrite user history, or delete remote branches without a separate request.
- Verify the pushed commit, public visibility and file list before reporting publication complete. Leave future permissions and repository settings unchanged unless requested.
