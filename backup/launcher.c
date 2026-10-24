// launchd starts this binary instead of the backup script. macOS charges file
// access by a launchd job's children to the job's own binary, so Full Disk
// Access is granted once to this launcher and survives restic upgrades.
// It runs argv[1..] as a child (not exec, which would hand over that identity)
// and exits with the child's status.
#include <errno.h>
#include <spawn.h>
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>

extern char **environ;

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s /absolute/path/to/program [args...]\n", argv[0]);
        return 64;
    }

    pid_t child;
    int spawn_error = posix_spawn(&child, argv[1], NULL, NULL, &argv[1], environ);
    if (spawn_error != 0) {
        fprintf(stderr, "%s: cannot run %s: %s\n", argv[0], argv[1], strerror(spawn_error));
        return 71;
    }

    int status;
    while (waitpid(child, &status, 0) < 0) {
        if (errno != EINTR) {
            perror("waitpid");
            return 71;
        }
    }
    return WIFEXITED(status) ? WEXITSTATUS(status) : 128 + WTERMSIG(status);
}
