%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

extern FILE* yyin;
int yylex();
void yyerror(char* s);

FILE *tac;
FILE *tc;

// Temp variables for TAC
char t[50][10];
int tcount = 0;

char* createTemp() {
    sprintf(t[tcount], "t%d", tcount+1);
    return t[tcount++];
}

// Registers for assembly
char r[50][10];
int rcount = 0;

char* assignReg() {
    sprintf(r[rcount], "R%d", rcount);
    return r[rcount++];
}

// Stack for assembly evaluation
char* regStack[50];
int top = -1;

void push(char* x) { regStack[++top] = x; }
char* pop() { return regStack[top--]; }

%}

%union {
    char str[20]; // for IDs, NUM, temp variables
    int op;       // for OpAssign codes
}

%token <str> ID NUM
%token NL
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN POW_ASSIGN
%token AND OR NOT
%token POW INTDIV

%type <str> E
%type <op> OpAssign

%left OR
%left AND
%left NOT
%left '+' '-'
%left '*' '/' INTDIV '%'
%right POW
%right UMINUS

%%

P   : P S
    | S
;

S   : ID '=' E NL {
            fprintf(tac, "%s = %s\n", $1, $3);

            char* reg = pop();
            fprintf(tc, "MOV %s, %s\n", $1, reg);

            tcount = 0; rcount = 0; top = -1;
        }
    | ID OpAssign E NL {
            char* temp = createTemp();

            switch($2) {
                case 1: fprintf(tac, "%s = %s + %s\n", temp, $1, $3); break;
                case 2: fprintf(tac, "%s = %s - %s\n", temp, $1, $3); break;
                case 3: fprintf(tac, "%s = %s * %s\n", temp, $1, $3); break;
                case 4: fprintf(tac, "%s = %s / %s\n", temp, $1, $3); break;
                case 5: fprintf(tac, "%s = %s %% %s\n", temp, $1, $3); break;
                case 6: fprintf(tac, "%s = %s ** %s\n", temp, $1, $3); break;
            }

            fprintf(tac, "%s = %s\n", $1, temp);

            // Assembly
            char* rop = pop();
            char* lop = assignReg();
            fprintf(tc, "MOV %s, %s\n", lop, $1);

            if($2==1) fprintf(tc, "ADD %s, %s\n", lop, rop);
            if($2==2) fprintf(tc, "SUB %s, %s\n", lop, rop);
            if($2==3) fprintf(tc, "MUL %s, %s\n", lop, rop);
            if($2==4) fprintf(tc, "DIV %s, %s\n", lop, rop);
            if($2==5) fprintf(tc, "MOD %s, %s\n", lop, rop);
            if($2==6) fprintf(tc, "POW %s, %s\n", lop, rop);

            fprintf(tc, "MOV %s, %s\n", $1, lop);

            tcount = 0; rcount = 0; top = -1;
        }
;

OpAssign:
      ADD_ASSIGN { $$ = 1; }
    | SUB_ASSIGN { $$ = 2; }
    | MUL_ASSIGN { $$ = 3; }
    | DIV_ASSIGN { $$ = 4; }
    | MOD_ASSIGN { $$ = 5; }
    | POW_ASSIGN { $$ = 6; }
;

E   : E '+' E {
            strcpy($$, createTemp());
            fprintf(tac, "%s = %s + %s\n", $$, $1, $3);

            char* rop = pop();
            char* lop = pop();
            fprintf(tc, "ADD %s, %s\n", lop, rop);
            push(lop);
        }
    | E '-' E {
            strcpy($$, createTemp());
            fprintf(tac, "%s = %s - %s\n", $$, $1, $3);

            char* rop = pop();
            char* lop = pop();
            fprintf(tc, "SUB %s, %s\n", lop, rop);
            push(lop);
        }
    | E '*' E {
            strcpy($$, createTemp());
            fprintf(tac, "%s = %s * %s\n", $$, $1, $3);

            char* rop = pop();
            char* lop = pop();
            fprintf(tc, "MUL %s, %s\n", lop, rop);
            push(lop);
        }
    | E '/' E {
            strcpy($$, createTemp());
            fprintf(tac, "%s = %s / %s\n", $$, $1, $3);

            char* rop = pop();
            char* lop = pop();
            fprintf(tc, "DIV %s, %s\n", lop, rop);
            push(lop);
        }
    | E INTDIV E {
            strcpy($$, createTemp());
            fprintf(tac, "%s = %s // %s\n", $$, $1, $3);

            char* rop = pop();
            char* lop = pop();
            fprintf(tc, "IDIV %s, %s\n", lop, rop);
            push(lop);
        }
    | E POW E {
            strcpy($$, createTemp());
            fprintf(tac, "%s = %s ** %s\n", $$, $1, $3);

            char* rop = pop();
            char* lop = pop();
            fprintf(tc, "POW %s, %s\n", lop, rop);
            push(lop);
        }
    | '(' E ')' { strcpy($$, $2); }
    | NUM { strcpy($$, $1); char imm[10]; sprintf(imm, "#%s", $1); push(imm); }
    | ID { strcpy($$, $1); char* r = assignReg(); fprintf(tc, "MOV %s, %s\n", r, $1); push(r); }
    | NOT E {
            strcpy($$, createTemp());
            fprintf(tac, "%s = ! %s\n", $$, $2);

            char* r = pop();
            char* res = assignReg();
            fprintf(tc, "MOV %s, %s\nNOT %s\n", res, r, res);
            push(res);
        }
;

%%

void yyerror(char* s) { printf("Syntax Error: %s\n", s); }

int main() {
    yyin = fopen("lab6task1.txt", "r");
    tac = fopen("tac.txt", "w");
    tc = fopen("tc.txt", "w");

    yyparse();

    fclose(tac);
    fclose(tc);
    return 0;
}
