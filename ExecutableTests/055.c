int main()
{
    int a[2];
    int *p;
    p = a;
    *(p + 1) = 5;
    return *(a + 1);
}
