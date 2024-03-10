#define VGA_ADDRESS 0xB8000
#define BUFSIZE 2200

char *videobuffer = (char *)0xB8000;

int main(int disknum) {
    videobuffer[0] = 'X';
    return 0;
}
