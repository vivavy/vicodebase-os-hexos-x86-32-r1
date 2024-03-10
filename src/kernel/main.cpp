#define VGA_ADDRESS 0xB8000
#define BUFSIZE 2200

extern "C" char videobuffer[BUFSIZE];

int main(int disknum) {
    videobuffer[0] = 'X';
    return 0;
}
