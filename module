#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/uaccess.h>
#include <linux/ktime.h>
#include <linux/timekeeping.h>
#include <linux/version.h>

MODULE_LICENSE("GPL");

#define PROC_NAME "tsulab"
// До начала сессии(10 января 27 года)
#define TARGET_TIMESTAMP 1799539200

static struct proc_dir_entry *proc_file;

static ssize_t tsulab_read(struct file *file, char __user *buffer, size_t buffer_length, loff_t *offset)
{
    char message[64];
    int len;
    time64_t now;
    time64_t seconds_left;

    // Если смещение не 0, значит данные уже прочитаны
    if (*offset != 0)
    {
        return 0;
    }
    // Получаем текущее время в секундах
    now = ktime_get_real_seconds();
    
    // Вычисляем оставшееся время
    // Если целевая дата ещё не наступила - считаем разницу 
    if (now < TARGET_TIMESTAMP)
    {
        seconds_left = TARGET_TIMESTAMP - now;
        len = snprintf(message, sizeof(message), "Seconds until session start: %lld\n", seconds_left);
    } 
    // Если наступила
    else 
    {
        len = snprintf(message, sizeof(message), "The session has already started!\n");
    }

    // Проверяем, что буфер пользователя достаточно велик
    if (buffer_length < len)
    {
        return -EINVAL;
    }
    // Копируем данные в пространство пользователя
    if (copy_to_user(buffer, message, len))
    {
        return -EFAULT;
    }
    *offset += len;
    return len;
}

// Проверка версии ядра
#if LINUX_VERSION_CODE >= KERNEL_VERSION(5, 6, 0)
static const struct proc_ops tsulab_proc_ops = 
{
    .proc_read = tsulab_read,
};
#else
static const struct file_operations tsulab_proc_ops = 
{
    .read = tsulab_read,
};
#endif

static int __init tsulab_init(void)
{
    pr_info("Welcome to the Tomsk State University\n");

    // Создаём файл в /proc
    proc_file = proc_create(PROC_NAME, 0444, NULL, &tsulab_proc_ops);
    if (!proc_file)
    {
        pr_err("Failed to create /proc/%s\n", PROC_NAME);
        return -ENOMEM;
    }

    pr_info("/proc/%s created successfully\n", PROC_NAME);
    return 0;
}

static void __exit tsulab_exit(void)
{
    // Удаляем файл из /proc
    if (proc_file)
    {
        proc_remove(proc_file);
    }
    pr_info("Tomsk State University forever!\n");
}

module_init(tsulab_init);
module_exit(tsulab_exit);
