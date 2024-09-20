/*
This program should have:
0 Errors in main
2 Errors in func1
1 Error in func2
*/

int func1(int input) {
    printf('This number should be 3 times bigger');
    
    int num = input * 3;

    printf("Then reduced by 5 \k");

    return num / 5;
}

int func2(int input) {
    printf("This string should not be capped);

    int num = input * 55;

    printf(...until the very end");

    return input * 2;
}

int main() {
    int newInt = 9;

    int func1Int = func1(newInt);
    int func2Int = func2(func1Int);

    finalInt = func1Int + func2Int;

    return finalInt;
}
