
/* Simple test program. This should return no errors */

int main() {
    int setInt = 99, nextInt = 100;

    printf("If setInt is one less than nextInt, this program should return true \n");

    setInt++;

    if (setInt == nextInt) printf("true");
    else printf("false");

    return 0;
}
