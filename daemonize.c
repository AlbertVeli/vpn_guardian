/* All Rights Reversed - No Rights Reserved
 *
 * DISCLAIMER
 * ==========
 * I can not be held responsible if this program messes
 * anything up (except your mind, I'm responsible for that).
 *
 * Written by ILEV Trebla at Sweetmorn,
 * the 64th day of The Aftermath in the YOLD 3180
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

static void waste_descriptors(void)
{
    /* Close stdin, stdout and stderr */
    if (close(0) < 0) perror("close 0");
    if (close(1) < 0) perror("close 1");
    if (close(2) < 0) perror("close 2");

    /* and point them to /dev/null */
    open("/dev/null", O_RDONLY, 0644);
    open("/dev/null", O_WRONLY, 0644);
    open("/dev/null", O_WRONLY, 0644);
}


static int daemonize_cmd(const char *cmd)
{
    pid_t pid;
    int ret;

    if (!cmd) {
        fprintf(stderr, "%s: cmd is NULL\n", __FUNCTION__);
        return 1;
    }

    /* fork so new process != group leader */
    pid = fork();
    if (pid < 0) {
        perror("daemonize_cmd (parent): first fork()");
        return 2;
    }

    if (pid > 0) {
        /* Return in parent */
        return 0;
    }

    /* First child */

    /* setsid to become process and session group leader */
    if (setsid() < 0) {
        perror("daemonize_cmd (child 1): setsid()");
        _exit(1);
    }

    /* fork again so the parent, (the session group leader), can exit. */
    pid = fork();
    if (pid < 0) {
        perror("daemonize_cmd (child 1): second fork()");
        _exit(1);
    }

    if (pid > 0) {
        /* exit first child */
        _exit(0);
    }

    /* Grandchild, at this stage fully detached from grandfather process */

    ret = chdir("/");
    if (ret) {
        perror("Warning: could not chdir to /");
    }

    umask(022);

    /* Close stdin, stdout and stderr */
    waste_descriptors();

    /* Run command as daemon */
    ret = system(cmd);

    /* exit grandchild */
    _exit(0);
}


/*
 * ███╗   ███╗ █████╗ ██╗███╗   ██╗
 * ████╗ ████║██╔══██╗██║████╗  ██║
 * ██╔████╔██║███████║██║██╔██╗ ██║
 * ██║╚██╔╝██║██╔══██║██║██║╚██╗██║
 * ██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
 * ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
 */

int main(int argc, char **argv)
{
    int ret;

    if (argc != 2) {
        fprintf(stderr,
                "\n"
                " ┌┬┐┌─┐┌─┐┌┬┐┌─┐┌┐┌┬┌─┐┌─┐\n"
                "  ││├─┤├┤ ││││ │││││┌─┘├┤\n"
                " ─┴┘┴ ┴└─┘┴ ┴└─┘┘└┘┴└─┘└─┘\n\n"
                "Usage: %s <full path to command>\n\n"
                "       Runs the command detached from the parent process so it\n"
                "       continues to run even if the parent process is killed.\n\n",
                argv[0]);
        return 1;
    }

    ret = daemonize_cmd(argv[1]);

    if (ret) {
        fprintf(stderr, "daemonize_cmd(\"%s\") exited with status %d\n", argv[1], ret);
    }

    return ret;
}


/**
 * Local Variables:
 * mode: c
 * indent-tabs-mode: nil
 * c-basic-offset: 3
 * End:
 */
