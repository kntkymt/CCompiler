char *sub() { return "hoge"; }
int main()
{
    char *x;
    x = sub();
    return x[0];
}
