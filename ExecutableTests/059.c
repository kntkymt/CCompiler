int main()
{
    int a[3];
    int b;
    b = 1;
    a[b] = 7;
    a[b + 1] = 10;
    return a[b] + a[b + 1];
}
