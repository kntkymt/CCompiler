int main()
{
    int a;
    int b;
    int i;
    a = 0;
    b = 0;
    for (i = 0; i < 10; i = i + 1)
    {
        a = a + 3;
        b = a;
    }
    return b;
}
