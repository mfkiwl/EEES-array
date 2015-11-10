#ifndef __FIO_ALT_H__
#define __FIO_ALT_H__

unsigned int FGETC();
int  FSEEK(int offset, int start);
long FTELL();

int FOPEN(char* file, char* mode);
void FCLOSE();

#endif
