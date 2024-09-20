
/* definitions */

%{
#include<stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tokendef.h"

int scancol = 0;
int yycol = 1;
int scanlineno = 0;
int yyval; 
char* yyerror;
char *yyoutput;
void updateCol(); //TODO: Implement this function to keep track of column numbers
void countLines(); //TODO: Implement this function to keep track of line numbers
int processString(); //TODO: Implement this function to check for illegal escape sequences in string literals and print out escape sequences correctly.
%}


newline         \n			
whitespace      [ \t]+				
integer         [1-9][0-9]*|0[^0-9]	
character       \'([^\']|\\[\\|n|t|\'])\'		

string      	\"(\\[\"]|[^"\n])*\"
untermstring 	\"(\\[\"]|[^"\n])*[^"\n]$
multlnstring  	\"(\\[\"]|[^"])+(\\[\"]|[^"\n])+\"




comment         \/\*([^\n]|\/|\*)*\*\/
multlncomment   \/\*([^\*\/]|\\|[\*])+([^\*\/\n]|\\|[\*])+\*\/
untermcomment   \/\*([^\n\*\/]|\*|\/)*[^\n\*\/]$

identifier      [a-zA-z][a-zA-Z0-9]*
illidentifier   [0-9][a-zA-Z]+

integerlead0    0[0-9]+

yylineno = 1;

%%

 /* rules */


 /* Keywords */;

if		{yycol += 2; return KWD_IF;}
else 	{yycol += 4; return KWD_ELSE;}
while 	{yycol += 5; return KWD_WHILE;}
int		{yycol += 3; return KWD_INT;}
string 	{yycol += 6; return KWD_STRING;}
char	{yycol += 4; return KWD_CHAR;}
return	{yycol += 6; return KWD_RETURN;}
void	{yycol += 4; return KWD_VOID;}

 /* Operators */;

\+		{yycol += 1; return OPER_ADD;}
\-		{yycol += 1; return OPER_SUB;}
\*		{yycol += 1; return OPER_MUL;}
\/		{yycol += 1; return OPER_DIV;}
\%		{yycol += 1; return OPER_MOD;}
\<		{yycol += 1; return OPER_LT;}
\> 		{yycol += 1; return OPER_GT;}
\<\= 	{yycol += 2; return OPER_LTE;}
\>\=	{yycol += 2; return OPER_GTE;}
\=\= 	{yycol += 2; return OPER_EQ;}
\!\=	{yycol += 2; return OPER_NEQ;}
\=		{yycol += 2; return OPER_ASGN;}
\[		{yycol += 1; return LSQ_BRKT;}
\]		{yycol += 1; return RSQ_BRKT;}
\{		{yycol += 1; return LCRLY_BRKT;}
\}		{yycol += 1; return RCRLY_BRKT;}
\(		{yycol += 1; return LPAREN;}
\)		{yycol += 1; return RPAREN;}
\,		{yycol += 1; return COMMA;}
\;		{yycol += 1; return SEMICLN;}
\@		{yycol += 1; return OPER_AT;}
\+\+	{yycol += 2; return OPER_INC;}
\-\-	{yycol += 2; return OPER_DEC;}
\&&		{yycol += 2; return OPER_AND;}
\|\|	{yycol += 2; return OPER_OR;}
\!		{yycol += 1; return OPER_NOT;}

 /* Identifiers */;
{identifier}    {yycol += yyleng; return ID;}
{illidentifier} {yycol += yyleng; yyerror = "Illegal identifier"; return ERROR;}

 /* Constants */;
{integer}       {yycol += yyleng; return INTCONST;}
{integerlead0}  {yycol += yyleng; yyerror = "Integers may not have leading zeros"; return ERROR;}
{character}     {yycol += 3; 
				int charLeng = yyleng;
				if(charLeng == 3){
					char c = yytext[1]; 
					yyval = (int)c;
				}
				else if(charLeng == 4){
					if (yytext[1] = '\\'){
						switch(yytext[2]){
							case 'b':
								yyval = 8;
								break;
							case 't':
								yyval = 9;
								break;
							case 'n':
								yyval = 10;
								break;
							case '\\':
								yyval = 92;
								break;
						}

					}
				}
				return CHARCONST;} 

{string}        {updateCol(); return processString();}
{untermstring}  {updateCol(); yyerror = "Unterminated string"; return ERROR;}
{multlnstring}  {updateCol(); yyerror = "String spans multiple lines"; return ERROR;} 

 /* Comments */;
{comment}       {yycol += yyleng; return CMMNT;}
{untermcomment} {yycol += yyleng; yyerror = "Unterminated comments"; return ERROR;}
{multlncomment} {updateCol(); return MULTLN_CMMNT;}

 /* Other */;
{newline}       	{yycol = 1; yylineno++;} 
{whitespace}   		{/*Take no actions for whiteline*/}
.               	{return ILLEGAL_TOK;}

%%

/* user routines */

void updateCol(){
	char *copyChar; 
	copyChar = (char*)malloc(yyleng);
	strcpy(copyChar, yytext);
	char *ptr = copyChar;
	
	while(*ptr != '\0'){
		if (*ptr == '\n'){
			countLines();
		}else{
			scancol++;
		}
		ptr++;
	}
	yycol = yycol + scancol;
	yylineno += scanlineno;
}	

void countLines(){
	scanlineno++;
	scancol = 1;
}


int processString(){
	int yy_index;
	int buffer;
	for(yy_index = 0; yy_index < yyleng; yy_index++){
		if (yytext[yy_index] == '\\'){
			buffer = yy_index + 1; 
			if((yytext[buffer] != 'n')&&(yytext[buffer] != 't')){
				if((yytext[buffer] != '\"')&&(yytext[buffer] != '\\')){
					yyerror = "Bad escaped sequence found in String";
					return ERROR;
				}
			if(yytext[buffer] == '\\'){
					yy_index++;	//Skip to the next position in yytext since // could cause some false positive
				}
			}
		}
	}
	
	yyoutput = (char*)malloc(yyleng + 1);
	int nyy_index, nbuffer;
	char *oyy_pntr = yyoutput;
	for(nyy_index = 0; nyy_index < yyleng; nyy_index++){
		if(yytext[nyy_index] == '\\'){
			nbuffer = nyy_index + 1;
			switch(yytext[nbuffer]){
				case 'n':
					*oyy_pntr = '\n';
					break;
				case 't':
					*oyy_pntr = '\t';
					break;
				case '\"':
					*oyy_pntr = '\"';
					break;
				case '\\':
					*oyy_pntr = '\\';
					break;
			}
			nyy_index++;
		}
		else{
			*oyy_pntr = yytext[nyy_index];
		}
		oyy_pntr++;
	}
	return STRCONST;
}

