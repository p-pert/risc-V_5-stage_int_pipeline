 #include <stdio.h>
 
 int main()
 {
    unsigned long long int a = 4294967294; // more than 32 bits so It uses mul and not mulw
    unsigned long long int b = 4294967294;
    //unsigned long long int a = 4; // more than 32 bits so It uses mul and not mulw
    //unsigned long long int b = 7;
    // int c[4];

    // for(int i =0; i<3; i++){
    //   c[i] = a*(b+i); 
    // }
    unsigned long long int c = a* b;

    return 0;
 }