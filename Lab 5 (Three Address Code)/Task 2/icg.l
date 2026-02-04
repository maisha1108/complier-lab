%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "icg.tab.h"
%}

DIGIT    [0-9]
LETTER   [a-zA-Z]
ID       {LETTER}({LETTER}|{DIGIT})*
NUMBER   {DIGIT}+
WS       [ \t]

%%

\n         { return NEWLINE; }
{WS}+      { }

"sqrt"     { return SQRT; }
"pow"      { return POW; }
"log"      { return LOG; }
"exp"      { return EXP; }
"sin"      { return SIN; }
"cos"      { return COS; }
"tan"      { return TAN; }
"abs"      { return ABS; }

"="        { return '='; }
"+"        { return '+'; }
"-"        { return '-'; }
"*"        { return '*'; }
"/"        { return '/'; }
"%"        { return '%'; }
"("        { return '('; }
")"        { return ')'; }
","        { return ','; }

{ID}       {
    yylval.str = strdup(yytext);
    return ID;
}

{NUMBER}   {
    yylval.str = strdup(yytext);
    return NUM;
}

.          { 
    // Silently ignore unexpected characters
    return yytext[0]; 
}

%%

int yywrap() {
    return 1;
}