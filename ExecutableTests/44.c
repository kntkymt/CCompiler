int main()
{
    int a;
    int d;
    int *b;
    int **c;
    a = 5;
    d = 10;
    b = &a;
    c = &b;
    *c = &d;
    **c = 30;
    return d;
}
