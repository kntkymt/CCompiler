int main()
{
    int a;
    int b;
    int *c;
    a = 5;
    b = 10;
    c = &b;
    c = c + 1;
    *c = 15;
    return a;
}
