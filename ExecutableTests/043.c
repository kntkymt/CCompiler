int main()
{
    int a;
    int *b;
    int **c;
    a = 5;
    b = &a;
    c = &b;
    **c = 20;
    return a;
}
