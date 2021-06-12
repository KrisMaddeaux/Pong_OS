#ifndef UTIL_H
#define UTIL_H

typedef unsigned char u8;

static void MemCopy(void* dst, void* src, const int length)
{
    u8* d = dst;
    u8* s = src;

    for (int i = 0; i < length; i++)
    {
        d[i] = s[i];
    }
}

#endif
