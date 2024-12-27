#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE_LENGTH 1024

void replace_line_in_file(const char *filename, const char *original, const char *modified, FILE *log_file, int dry_run) {
	//printf("%s\n",filename);

    FILE *file = fopen(filename, "r");
    if (!file) {
        perror(filename);
        return;
    }

    char temp_filename[MAX_LINE_LENGTH];
    snprintf(temp_filename, sizeof(temp_filename), "%s.tmp", filename);

    FILE *temp_file = fopen(temp_filename, "w");
    if (!temp_file) {
        perror("Error opening temporary file");
        fclose(file);
        return;
    }

    char line[MAX_LINE_LENGTH];
    int line_number = 0;
    int replaced = 0;

    while (fgets(line, sizeof(line), file)) {
        line_number++;
        if (strstr(line, modified)) {
            fprintf(log_file, "File: %s\n", filename);
            fprintf(log_file, "Line %d: Replacing \"%s\" with \"%s\"\n", line_number, modified, original);
            replaced = 1;
            if (!dry_run) {
                fprintf(temp_file, "%s", original);
            } else {
                fprintf(temp_file, "%s", line);
            }
        } else {
            fprintf(temp_file, "%s", line);
        }
    }

    fclose(file);
    fclose(temp_file);

    if (replaced && !dry_run) {
        remove(filename);
        rename(temp_filename, filename);
    } else {
        remove(temp_filename);
    }
}

void process_output_file(const char *output_filename, FILE *log_file, int dry_run) {
    FILE *output_file = fopen(output_filename, "r");
    if (!output_file) {
        perror("Error opening output file");
        return;
    }

    char line[MAX_LINE_LENGTH];
    char filename[MAX_LINE_LENGTH];
    char original[MAX_LINE_LENGTH];
    char modified[MAX_LINE_LENGTH];

    while (fgets(line, sizeof(line), output_file)) {
        if (strncmp(line, "File: ", 6) == 0) {
            strcpy(filename, line + 6);
            filename[strcspn(filename, "\n")] = '\0';  // Remove newline character
        } else if (strncmp(line, "Original: ", 10) == 0) {
            strcpy(original, line + 10);
        } else if (strncmp(line, "Modified: ", 10) == 0) {
            strcpy(modified, line + 10);
            replace_line_in_file(filename, original, modified, log_file, dry_run);
        }
    }

    fclose(output_file);
}

int main(int argc, char *argv[]) {
    if (argc < 3 || argc > 4) {
        fprintf(stderr, "Usage: %s <output_file> <log_file> [--dry-run]\n", argv[0]);
        return 1;
    }

    const char *output_filename = argv[1];
    const char *log_filename = argv[2];
    int dry_run = (argc == 4 && strcmp(argv[3], "--dry-run") == 0);

    FILE *log_file = fopen(log_filename, "w");
    if (!log_file) {
        perror("Error opening log file");
        return 1;
    }

    process_output_file(output_filename, log_file, dry_run);

    fclose(log_file);

    printf("Processing complete. Log saved in %s\n", log_filename);
    return 0;
}
