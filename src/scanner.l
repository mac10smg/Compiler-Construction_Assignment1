
/* definitions */

%{
#include<stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tokendef.h"

int scancol = 1;
int yycol = 1;
int scanlineno = 1;
int yyval; 
char* yyerror;

void updateCol(); //TODO: Implement this function to keep track of column numbers
void countLines(); //TODO: Implement this function to keep track of line numbers
int processString(); //TODO: Implement this function to check for illegal escape sequences in string literals and print out escape sequences correctly.
%}


newline         \n	
enter 			\r		
whitespace      [ \t]+				
integer         [1-9][0-9]*|0[^0-9]	
character       \'([^\']|\\[\\nt\'])\'		

string      	\"(\\[\"]|[^"\n])*\" 
untermstring 	\"(\\[\"]|[^"\n])*[^"\n]$
multlnstring  	\"(\\[\"]|[^"])+(\\[\"]|[^"\n])+\"


longchar 		\'([^\']|\\[\\nt\']){whitespace}([^\']|\\[\\nt\'])+\'

comment         \/\*\/?([^\n\/]|[^\*]\/)*\*\/
multlncomment   \/\*\/?([^\/]|[^\*]\/)*\n([^\/]|[^\*]\/)*\*\/
untermcomment   \/\*[^\n]?\/?([^\n\/]|[^\*\n]\/[\*]?)*

identifier      [a-zA-z][a-zA-Z0-9]*
illidentifier   [0-9][a-zA-Z]+[a-zA-Z0-9]*

integerlead0    0[0-9]+

yylineno = 1;

%%

 /* rules */


 /* Keywords */;

if		{updateCol(); return KWD_IF;}
else 	{updateCol(); return KWD_ELSE;}
while 	{updateCol(); return KWD_WHILE;}
int		{updateCol(); return KWD_INT;}
string 	{updateCol(); return KWD_STRING;}
char	{updateCol(); return KWD_CHAR;}
return	{updateCol(); return KWD_RETURN;}
void	{updateCol(); return KWD_VOID;}

 /* Operators */;

\+		{updateCol(); return OPER_ADD;}
\-		{updateCol(); return OPER_SUB;}
\*		{updateCol(); return OPER_MUL;}
\/		{updateCol(); return OPER_DIV;}
\%		{updateCol(); return OPER_MOD;}
\<		{updateCol(); return OPER_LT;}
\> 		{updateCol(); return OPER_GT;}
\<\= 	{updateCol(); return OPER_LTE;}
\>\=	{updateCol(); return OPER_GTE;}
\=\= 	{updateCol(); return OPER_EQ;}
\!\=	{updateCol(); return OPER_NEQ;}
\=		{updateCol(); return OPER_ASGN;}
\[		{updateCol(); return LSQ_BRKT;}
\]		{updateCol(); return RSQ_BRKT;}
\{		{updateCol(); return LCRLY_BRKT;}
\}		{updateCol(); return RCRLY_BRKT;}
\(		{updateCol(); return LPAREN;}
\)		{updateCol(); return RPAREN;}
\,		{updateCol(); return COMMA;}
\;		{updateCol(); return SEMICLN;}
\@		{updateCol(); return OPER_AT;}
\+\+	{updateCol(); return OPER_INC;}
\-\-	{updateCol(); return OPER_DEC;}
\&&		{updateCol(); return OPER_AND;}
\|\|	{updateCol(); return OPER_OR;}
\!		{updateCol(); return OPER_NOT;}

 /* Identifiers */;
{identifier}    {updateCol(); return ID;}
{illidentifier} {updateCol(); yyerror = "Illegal identifier"; return ERROR;}

 /* Constants */;
{integer}       {updateCol(); return INTCONST;}
{integerlead0}  {updateCol(); yyerror = "Integers may not have leading zeros"; return ERROR;}
{longchar}		{updateCol(); yyerror ="Character constant too long for its type"; return ERROR;}
{character}     {updateCol(); 
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
{multlnstring}  {updateCol(); countLines(); yyerror = "String spans multiple lines"; return ERROR;} 

 /* Comments */;
{comment}       {updateCol(); return CMMNT;}
{untermcomment} {updateCol(); yyerror = "Unterminated comments"; return ERROR;}
{multlncomment} {updateCol(); countLines(); return MULTLN_CMMNT;} 

 /* Other */;
{newline}       	{scancol = 1; scanlineno++; yylineno = scanlineno;} 
{enter}				{/*Take no actions for enter*/}
{whitespace}   		{/*Take no actions for whiteline*/}
.               	{return ILLEGAL_TOK;}

%%

/* user routines */

void updateCol(){
	yycol = scancol;
	scancol += yyleng;
}	

void countLines(){
	for(int i = 0; i < yyleng; i++){
		if(yytext[i] == '\n'){
			scanlineno++;
			scancol = 1;
		}
	}
	yylineno = scanlineno;
}


int processString(){
	int yy_index;
	int buffer;

	/* First scan yytext as a string literal to check for illegal escaped sequence
	//This is quite simple, just need to keep track to pointer, one at the / and 
	//then one at one position at head of the previous pointer. Then, check if that 
	//character is valid, if not return error
	*/

	for(yy_index = 0; yy_index < yyleng; yy_index++){
		if (yytext[yy_index] == '\\'){
			buffer = yy_index + 1; 
			if((yytext[buffer] != 'n')&&(yytext[buffer] != 't')){
				if((yytext[buffer] != '\"')&&(yytext[buffer] != '\\')){
					yyerror = "Unrecognized escape character in String";
					return ERROR;
				}
			if(yytext[buffer] == '\\'){
					yy_index++;	//Skip to the next position in yytext since // could cause some false positive
				}
			}
		}
	}
	
	/*If the string have escape sequence and is illegal, then we don't need 
	//to bother to processed the string, else we need to process these string 
	*/
	char *yyoutput = (char*)malloc(yyleng + 1);
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

	*oyy_pntr = '\0'; //Make sure we terminate the string properly
	strcpy(yytext, yyoutput);
	free(yyoutput);
	return STRCONST;
}

