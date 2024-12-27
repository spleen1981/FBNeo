#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#define MAX_LINE_LENGTH 1024

void process_file(const char *filename, FILE *output_file) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Error opening file");
        return;
    }

    char line[MAX_LINE_LENGTH];
    int line_number = 0;

    while (fgets(line, sizeof(line), file)) {
	if (strstr(line, "#define") != NULL) {
            continue;
        }
        line_number++;
        char *pos = strstr(line, "BURN_ENDIAN_SWAP_INT");
        if (pos) {
            char *start = strchr(pos, '(');
            char *end = start;
            int open_parens = 1;

            while (open_parens > 0 && *end) {
                end++;
                if (*end == '(') open_parens++;
                if (*end == ')') open_parens--;
            }

            if (open_parens == 0) {
                char content[MAX_LINE_LENGTH];
                strncpy(content, start + 1, end - start - 1);
                content[end - start - 1] = '\0';

                char modified_line[MAX_LINE_LENGTH];
                strncpy(modified_line, line, pos - line);
                modified_line[pos - line] = '\0';
                strcat(modified_line, content);
                strcat(modified_line, end + 1);

                fprintf(output_file, "File: %s\n", filename);
                fprintf(output_file, "Original: %s", line);
                fprintf(output_file, "Modified: %s", modified_line);
                fprintf(output_file, "\n");
            }
        }
    }

    fclose(file);
}

void process_directory(const char *dirpath, FILE *output_file) {
    struct dirent *entry;
    DIR *dp = opendir(dirpath);

    if (!dp) {
        perror("Failed to open directory");
        return;
    }

    while ((entry = readdir(dp))) {
        char path[1024];
        snprintf(path, sizeof(path), "%s/%s", dirpath, entry->d_name);

        struct stat statbuf;
        if (stat(path, &statbuf) == -1) {
            perror("Failed to stat file");
            continue;
        }

        if (S_ISDIR(statbuf.st_mode)) {
            if (strcmp(entry->d_name, ".") != 0 && strcmp(entry->d_name, "..") != 0) {
                process_directory(path, output_file);
            }
        } else if (S_ISREG(statbuf.st_mode)) {
            const char *ext = strrchr(entry->d_name, '.');
            if (ext && (strcmp(ext, ".h") == 0 || strcmp(ext, ".c") == 0 || strcmp(ext, ".cpp") == 0)) {
                process_file(path, output_file);
            }
        }
    }

    closedir(dp);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <directory> <output_file>\n", argv[0]);
        return 1;
    }

    const char *directory = argv[1];
    const char *output_filename = argv[2];

    FILE *output_file = fopen(output_filename, "w");
    if (!output_file) {
        perror("Error opening output file");
        return 1;
    }

    printf("Starting processing...\n");  // Debug message
    process_directory(directory, output_file);

    fclose(output_file);

    printf("Processing complete. Results saved in %s\n", output_filename);
    return 0;
}
