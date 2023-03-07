#include <stdio.h>
#include <string.h>

void print_string(char* s);
void print_file(char* name);


#include <stdio.h>
#include <string.h>
#define _CRT_SECURE_NO_WARNINGS
void print_string(char* s);
void print_file(char* name);

int main() {
    char filename[128];
    print_string("Please enter file name:\n");
    if (fgets(filename, 128, stdin) != NULL) {
        filename[strlen(filename) - 1] = '\0';
        printf("filename = \"%s\"", filename);
    }
    print_file(filename);
    return 0;
}
