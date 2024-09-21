/* 
First section + comment should return no errors

second section + comment should return an error for an 
unrecognized escape and unterminated comment, respectively 
*/

if (99 == 88)
printf("this string should maybe appear");

else
printf("this string should contain an error \j");

/* Also I'm here and a valid comment, presumably */

/* I however am not valid, sad :(