int main()
{
    int a;
    a = 0;
    for (;; a = a + 1)
        if (a >= 10)
            return a;
}
