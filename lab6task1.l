%{
#include "lab6task1.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

DIGIT   [0-9]
ID      [a-zA-Z][a-zA-Z0-9]*
{NEWLINE}   { return NL; }
\r          { /* ignore CR */ }
{WS}        { /* ignore whitespace */ }


%%

"**="       { return POW_ASSIGN; }
"+="        { return ADD_ASSIGN; }
"-="        { return SUB_ASSIGN; }
"*="        { return MUL_ASSIGN; }
"/="        { return DIV_ASSIGN; }
"%="        { return MOD_ASSIGN; }
"="         { return '='; }
"**"        { return POW; }
"//"        { return INTDIV; }
"*"         { return '*'; }
"/"         { return '/'; }
"%"         { return '%'; }
"+"         { return '+'; }
"-"         { return '-'; }
"&&"        { return AND; }
"||"        { return OR; }
"!"         { return NOT; }
"("         { return '('; }
")"         { return ')'; }
{NEWLINE}   { return NL; }

{ID}        { strncpy(yylval.str, yytext, 19); yylval.str[19]='\0'; return ID; }
{DIGIT}+    { strncpy(yylval.str, yytext, 19); yylval.str[19]='\0'; return NUM; }

{WS}        { /* ignore whitespace */ }

.           { printf("Unknown character: %s\n", yytext); }

%%

int yywrap() { return 1; }
