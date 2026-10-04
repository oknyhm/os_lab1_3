// SPDX-License-Identifier: GPL-2.0
/*
 * oslab3_probe.c - A small, observable boot probe for OS lab 3.
 *
 * The module records the boot-relative time at which module_init() runs and
 * exposes the value through /proc/oslab3_boot.  It is intentionally simple:
 * the purpose is to connect kernel module initialization, procfs, the kernel
 * log and systemd-modules-load in one reproducible experiment.
 */

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/ktime.h>
#include <linux/math64.h>
#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/time.h>
#include <linux/utsname.h>

#define OSLAB3_PROC_NAME "oslab3_boot"

static u64 load_boottime_ns;
static struct proc_dir_entry *oslab3_proc_entry;

static int oslab3_proc_show(struct seq_file *stream, void *unused)
{
	u64 now_ns = ktime_get_boottime_ns();

	seq_puts(stream, "student=XXX\n");
	seq_printf(stream, "kernel=%s\n", utsname()->release);
	seq_printf(stream, "module_load_boottime_ms=%llu\n",
		   div_u64(load_boottime_ns, NSEC_PER_MSEC));
	seq_printf(stream, "current_boottime_ms=%llu\n",
		   div_u64(now_ns, NSEC_PER_MSEC));
	seq_puts(stream, "status=ready\n");

	return 0;
}

static int oslab3_proc_open(struct inode *inode, struct file *file)
{
	return single_open(file, oslab3_proc_show, NULL);
}

static const struct proc_ops oslab3_proc_ops = {
	.proc_open = oslab3_proc_open,
	.proc_read = seq_read,
	.proc_lseek = seq_lseek,
	.proc_release = single_release,
};

static int __init oslab3_probe_init(void)
{
	load_boottime_ns = ktime_get_boottime_ns();
	oslab3_proc_entry = proc_create(OSLAB3_PROC_NAME, 0444, NULL,
					 &oslab3_proc_ops);
	if (!oslab3_proc_entry)
		return -ENOMEM;

	pr_info("oslab3_probe: init at %llu ms on kernel %s\n",
		div_u64(load_boottime_ns, NSEC_PER_MSEC), utsname()->release);
	return 0;
}

static void __exit oslab3_probe_exit(void)
{
	proc_remove(oslab3_proc_entry);
	pr_info("oslab3_probe: exit\n");
}

module_init(oslab3_probe_init);
module_exit(oslab3_probe_exit);

MODULE_AUTHOR("XXX");
MODULE_DESCRIPTION("Observable boot probe for operating systems lab 3");
MODULE_LICENSE("GPL");

