%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    extern int yylex();
    extern char yytext[];
    int yydebug = 1;
    int decl_flag = 0;
%}
%union {
    char *program;
    // char statement[10000];
    char *statement;
    // char declar[5000];
    char *declar;
    // char expr[500];
    char *expr;
    // char ident[100];
    char *ident;
    // char additional[300];
    char *additional;

    char *type_list;

    int intVal; 
    char character[5];
    char str[300];
    double floatVal;
    double doubleVal;
    char type[50];
    char stmt[50];
    char op[5];
    char punc[5];
    char macros[20];
}
%token<ident> IDENT
%token<intVal> INTEGER
%token<floatVal> FLOATING
%token<character> CHARACTER
%token<str> STRING
%token<op> LEFT_SHIFT RIGHT_SHIFT
%token<op> LESS_OR_EQUAL GREATER_OR_EQUAL EQUALS NOT_EQUALS
%token<op> INC DEC 
%token<op> AND OR
%token<type> CONST SIGNED UNSIGNED SHORT LONG VOID INT CHAR FLOAT DOUBLE
%token<stmt> IF ELSE SWITCH CASE DEFAULT DO WHILE FOR RETURN BREAK CONTINUE


%type<op> pointer unary_op assignment_op
%type<declar> external_declaration declaration function_definition
%type<declar> init_declarator_list init_declarator
%type<declar> direct_declarator declarator declaration_list 

%type<program>program 

%type<statement> stmt compound_stmt //stmt_list
%type<statement> switch_clauses switch_clause labeled_stmt
%type<statement> expression_stmt selection_stmt iteration_stmt jump_stmt
%type<statement> compound_stmt_contents

%type<expr> initializer_list initializer
%type<expr> expression
%type<expr> assignment_expression
%type<expr> constant_expression
%type<expr> conditional_expression
%type<expr> logical_or_expression
%type<expr> logical_and_expression
%type<expr> inclusive_or_expression
%type<expr> exclusive_or_expression
%type<expr> and_expression
%type<expr> equality_expression
%type<expr> relational_expression
%type<expr> shift_expression
%type<expr> additive_expression
%type<expr> multiplicative_expression
%type<expr> cast_expression
%type<expr> unary_expression
%type<expr> postfix_expression
%type<expr> argument_expression_list
%type<expr> primary_expression

%type<type> type 
%type<type_list> type_list type_name
%type<additional> parameter_list identifier_list parameter_declaration
%type<additional> abstract_declarator direct_abstract_declarator

%right '='
%left '+' '-'
%left '*' '/' '%'

%start program

%%
program: external_declaration {printf("%s", $1); free($1);}
    | program external_declaration {
        printf("%s", $2);
        free($2);
    }
    ;
external_declaration: declaration {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
        free($1);
    }
    | function_definition {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
        free($1);
    }
    ;
declaration: type_list init_declarator_list ';'{
        if(decl_flag == 0){//scalar decl
            $$ = (char *)malloc((strlen($1) + strlen($2) + 40) * sizeof(char));
            sprintf($$, "<scalar_decl>%s%s;</scalar_decl>", $1, $2);
        }
        else if(decl_flag == 1){//array decl
            $$ = (char *)malloc((strlen($1) + strlen($2) + 40) * sizeof(char));
            sprintf($$, "<array_decl>%s%s;</array_decl>", $1, $2);
        }
        else if(decl_flag == 2){//function decl
            $$ = (char *)malloc((strlen($1) + strlen($2) + 40) * sizeof(char));
            sprintf($$, "<func_decl>%s%s;</func_decl>", $1, $2);
        }
    }
    ;
/* @@@ functions concerned @@@ */
stmt: compound_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    /* | switch_clauses {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    } */
    | expression_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | selection_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | iteration_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | jump_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
function_definition: type_list declarator compound_stmt {
        $$ = (char*)malloc((strlen($1) + strlen($2) + strlen($3) + 30) * sizeof(char));
        sprintf($$, "<func_def>%s%s%s</func_def>", $1, $2, $3);
    }
    | declarator compound_stmt{
        $$ = (char*)malloc((strlen($1) + strlen($2) + 30) * sizeof(char));
        sprintf($$, "<func_def>%s%s</func_def>", $1, $2);
    }
    | type_list declarator declaration_list compound_stmt {
        $$ = (char*)malloc((strlen($1) + strlen($2) + strlen($3) + strlen($4) + 30) * sizeof(char));
        sprintf($$, "<func_def>%s%s%s%s</func_def>", $1, $2, $3, $4);
    }
    | declarator declaration_list compound_stmt {
        $$ = (char*)malloc((strlen($1) + strlen($2) + strlen($3) + 30) * sizeof(char));
        sprintf($$, "<func_def>%s%s%s</func_def>", $1, $2, $3);
    }
    ;
declaration_list: declaration_list declaration {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | declaration {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
switch_clauses:  '{' switch_clause '}' {
        $$ = (char *)malloc((strlen($2) + 3) * sizeof(char));
        sprintf($$, "{%s}", $2);
    }
    /* |'{' switch_clauses switch_clause '}' {
        $$ = (char *)malloc((strlen($2) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "{%s%s}", $2, $3);
    } */
    | '{' '}' {
        $$ = (char *)malloc((3) * sizeof(char));
        sprintf($$, "%s", "{}");
    }
    ;
switch_clause: switch_clause stmt {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 20) * sizeof(char));
        if($2[0] == '{'){
            sprintf($$, "%s<stmt>%s</stmt>", $1, $2);
        }
        else {
            sprintf($$, "%s%s", $1, $2);
        }
    }
    | switch_clause labeled_stmt {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 2) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | labeled_stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
labeled_stmt: CASE expression ':' {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 3) * sizeof(char));
        sprintf($$, "%s%s:", $1, $2);
    }
    | DEFAULT ':' {
        $$ = (char *)malloc((strlen($1) + 3) * sizeof(char));
        sprintf($$, "%s:", $1);
    }
    ;
compound_stmt: '{' '}' {
        $$ = (char *)malloc(3 * sizeof(char));
        sprintf($$, "%s", "{}");
    }
    | '{' compound_stmt_contents '}' {
        $$ = (char *)malloc((strlen($2) + 3) * sizeof(char));
        sprintf($$, "{%s}", $2);
    }
    ; 
compound_stmt_contents: declaration {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | stmt {
        // printf("compound_stmt_content's stmt: %s\n", $1);
        // 
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        if($1[0] == '{'){
            sprintf($$, "<stmt>%s</stmt>", $1);
        }
        else {
            sprintf($$, "%s", $1);
        }
    }
    | compound_stmt_contents declaration {
        // printf("\ncompound_stmt_contents: declaration = %s\n", $2);
        $$ = (char *)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | compound_stmt_contents stmt {
        // printf("compound_stmt_contents' stmt: %s\n", $2);
        $$ = (char *)malloc((strlen($1) + strlen($2) + 20) * sizeof(char));
        if($2[0] == '{'){
            sprintf($$, "%s<stmt>%s</stmt>", $1, $2);
        }
        else {
            sprintf($$, "%s%s", $1, $2);
        }
    }
    ;
/* stmt_list: stmt {
        $$ = (char *)malloc((strlen($1) + 1) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | stmt_list stmt{
        $$ = (char *)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    ; */
expression_stmt: ';' {
        $$ = (char *)malloc((2) * sizeof(char));
        sprintf($$, "%s", ";");
    }
    | expression ';' {
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s;</stmt>", $1);
    }
    ;
selection_stmt: IF '(' expression ')' compound_stmt {
        $$ = (char *)malloc((strlen($1) + strlen($3) + strlen($5) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s(%s)%s</stmt>", $1, $3, $5);
    }
    | IF '(' expression ')' compound_stmt ELSE compound_stmt {
        int stmt_len = strlen($1) + strlen($3) + strlen($5) + strlen($6) + strlen($7);
        $$ = (char *)malloc((stmt_len + 20) * sizeof(char));
        sprintf($$, "<stmt>%s(%s)%s%s%s</stmt>", $1, $3, $5, $6, $7);
    }
    | SWITCH '(' expression ')'  switch_clauses  {
        $$ = (char *)malloc((strlen($1) + strlen($3) + strlen($5) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s(%s)%s</stmt>", $1, $3, $5);
    }
    ;
iteration_stmt: WHILE '(' expression ')' stmt {
        $$ = (char *)malloc((strlen($1) + strlen($3) + strlen($5) + 40) * sizeof(char));
        if($5[0] == '{'){
            sprintf($$, "<stmt>%s(%s)<stmt>%s</stmt></stmt>", $1, $3, $5);
        }
        else {
            sprintf($$, "<stmt>%s(%s)%s</stmt>", $1, $3, $5);
        }
    }
    | DO stmt WHILE '(' expression ')' ';' {
        int stmt_len = strlen($1) + strlen($2) + strlen($3) + strlen($5);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        if($2[0] == '{'){
            sprintf($$, "<stmt>%s<stmt>%s</stmt>%s(%s);</stmt>", $1, $2, $3, $5);
        }
        else {
            sprintf($$, "<stmt>%s%s%s(%s);</stmt>", $1, $2, $3, $5);
        }
    }
    | FOR '(' ';' ';' ')' stmt { // no expr in for
        int stmt_len = strlen($1) + strlen($6);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        
        if($6[0] == '{'){
            sprintf($$, "<stmt>%s(;;)<stmt>%s</stmt></stmt>", $1, $6);
        }
        else {
            sprintf($$, "<stmt>%s(;;)%s</stmt>", $1, $6);
        }
    }
    | FOR '(' expression ';' ';' ')' stmt { // 1 expr in for (left)
        int stmt_len = strlen($1) + strlen($3) + strlen($7);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        
        if($7[0] == '{'){
            sprintf($$, "<stmt>%s(%s;;)<stmt>%s</stmt></stmt>", $1, $3, $7);
        }
        else {
            sprintf($$, "<stmt>%s(%s;;)%s</stmt>", $1, $3, $7);
        }
    }
    | FOR '(' ';' expression ';' ')' stmt { // 1 expr in for (mid)
        int stmt_len = strlen($1) + strlen($4) + strlen($7);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        
        if($7[0] == '{'){
            sprintf($$, "<stmt>%s(;%s;)<stmt>%s</stmt></stmt>", $1, $4, $7);
        }
        else {
            sprintf($$, "<stmt>%s(;%s;)%s</stmt>", $1, $4, $7);
        }
    }
    | FOR '(' ';' ';' expression ')' stmt { // 1 expr in for (right)
        int stmt_len = strlen($1) + strlen($5) + strlen($7);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        
        if($7[0] == '{'){
            sprintf($$, "<stmt>%s(;;%s)<stmt>%s</stmt></stmt>", $1, $5, $7);
        }
        else {
            sprintf($$, "<stmt>%s(;;%s)%s</stmt>", $1, $5, $7);
        }
    }
    | FOR '(' expression ';' expression ';' ')' stmt { // 2 expr in for (no right)
        int stmt_len = strlen($1) + strlen($3) + strlen($5) + strlen($8);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        if($8[0] == '{'){
            sprintf($$, "<stmt>%s(%s;%s;)<stmt>%s</stmt></stmt>", $1, $3, $5, $8);
        }
        else {
            sprintf($$, "<stmt>%s(%s;%s;)%s</stmt>", $1, $3, $5, $8);
        }
    }
    | FOR '(' expression ';'  ';' expression ')' stmt { // 2 expr in for (no mid)
        int stmt_len = strlen($1) + strlen($3) + strlen($6) + strlen($8);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        if($8[0] == '{'){
            sprintf($$, "<stmt>%s(%s;;%s)<stmt>%s</stmt></stmt>", $1, $3, $6, $8);
        }
        else {
            sprintf($$, "<stmt>%s(%s;;%s)%s</stmt>", $1, $3, $6, $8);
        }
    }
    | FOR '(' ';' expression ';' expression ')' stmt { // 2 expr in for (no left)
        int stmt_len = strlen($1) + strlen($4) + strlen($6) + strlen($8);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        if($8[0] == '{'){
            sprintf($$, "<stmt>%s(;%s;%s)<stmt>%s</stmt></stmt>", $1, $4, $6, $8);
        }
        else {
            sprintf($$, "<stmt>%s(;%s;%s)%s</stmt>", $1, $4, $6, $8);
        }
    }
    | FOR '(' expression ';' expression ';' expression ')' stmt { // 3 expr in for
        int stmt_len = strlen($1) + strlen($3) + strlen($5) + strlen($7) + strlen($9);
        $$ = (char *)malloc((stmt_len + 40) * sizeof(char));
        if($9[0] == '{'){
            sprintf($$, "<stmt>%s(%s;%s;%s)<stmt>%s</stmt></stmt>", $1, $3, $5, $7, $9);
        }
        else {
            sprintf($$, "<stmt>%s(%s;%s;%s)%s</stmt>", $1, $3, $5, $7, $9);
        }
    }
    ;
jump_stmt: CONTINUE ';' {
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s;</stmt>", $1);
    }
    | BREAK ';' {
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s;</stmt>", $1);
    }
    | RETURN ';' {
        $$ = (char *)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s;</stmt>", $1);
    }
    | RETURN expression ';' {
        $$ = (char *)malloc((strlen($1) + strlen($2) + 20) * sizeof(char));
        sprintf($$, "<stmt>%s%s;</stmt>", $1, $2);
    }
    ;
/* @@@variables concerned@@@ */
type_list: type_list type {
        $$ = (char*)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | type {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
type: CONST {sprintf($$, "%s", $1);}
    | SIGNED {sprintf($$, "%s", $1);}
    | UNSIGNED {sprintf($$, "%s", $1);}
    | SHORT {sprintf($$, "%s", $1);}
    | LONG {sprintf($$, "%s", $1);}
    | VOID {sprintf($$, "%s", $1);}
    | INT {sprintf($$, "%s", $1);}
    | CHAR {sprintf($$, "%s", $1);}
    | FLOAT {sprintf($$, "%s", $1);}
    | DOUBLE {sprintf($$, "%s", $1);}
    ;
init_declarator_list: init_declarator_list ',' init_declarator{
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    | init_declarator { 
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    ;
/* ### ASSIGNMENT lefthand-side start ### */
init_declarator: declarator {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    | declarator '=' initializer {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s=%s", $1, $3);
    }
    ;
declarator: pointer direct_declarator{
        $$ = (char*)malloc((strlen($1) + strlen($2) + 1) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | direct_declarator {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    ;
direct_declarator: IDENT {
        decl_flag = 0;
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1); 
    }
    | direct_declarator '[' expression ']'{
        decl_flag = 1;
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s[%s]", $1, $3);
    }
    | direct_declarator '[' ']'{
        decl_flag = 1;
        $$ = (char*)malloc((strlen($1) + 3) * sizeof(char));
        sprintf($$, "%s[]", $1);
    }
    | '(' declarator ')'{
        $$ = (char*)malloc((strlen($2) + 3) * sizeof(char));
        sprintf($$, "(%s)", $2);
    }
    | direct_declarator '(' parameter_list ')'{
        decl_flag = 2;
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s(%s)", $1, $3);
    }
    | direct_declarator '(' identifier_list ')'{
        decl_flag = 2;
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s(%s)", $1, $3);
    }
    | direct_declarator '(' ')'{
        decl_flag = 2;
        $$ = (char*)malloc((strlen($1) + 3) * sizeof(char));
        sprintf($$, "%s()", $1);
    }
    ;
parameter_list: parameter_declaration {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | parameter_list ',' parameter_declaration {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
parameter_declaration: type_list declarator {
        $$ = (char*)malloc((strlen($1) + strlen($2)) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | type_list abstract_declarator {
        $$ = (char*)malloc((strlen($1) + strlen($2)) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    | type_list {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
identifier_list: IDENT { 
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | identifier_list ',' IDENT {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
pointer: '*' {sprintf($$, "%s", "*");}
    | pointer '*' {sprintf($$, "%s%s", $1, "*");}
    ;
/* ### ASSIGNMENT left hand side end ### */
/* ### ASSIGNMENT right hand side start ### */
initializer: assignment_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | '{' initializer_list '}' {
        $$ = (char*)malloc((strlen($2) + 3) * sizeof(char));
        sprintf($$, "{%s}", $2);
    }
    ;
initializer_list: initializer {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | initializer_list ',' initializer {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
/* ### ASSIGNMENT right hand side end ### */

/* expression rules start*/
expression: assignment_expression {
        // printf("expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | expression ',' assignment_expression{
        $$ = (char*)malloc((strlen($1) + strlen($3) + 3) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
assignment_expression: conditional_expression {
        // printf("assign_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | constant_expression assignment_op assignment_expression{
        $$ = (char*)malloc((strlen($1) + strlen($2) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s%s%s</expr>", $1, $2, $3);
    }
    ;
assignment_op: '=' {sprintf($$, "%s", "=");}
    ;
constant_expression: conditional_expression {
        // printf("constant_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    ;
conditional_expression: logical_or_expression {
        // printf("conditional_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    | logical_or_expression '?' expression ':' conditional_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + strlen($5) + 40) * sizeof(char));
        sprintf($$, "<expr>%s?<expr>%s</expr>:%s</expr>", $1, $3, $5);
    }
    ;
logical_or_expression: logical_and_expression {
        // printf("logical_or_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    | logical_or_expression OR logical_and_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s||%s</expr>", $1, $3);
    }
    ;
logical_and_expression: inclusive_or_expression {
        // printf("logical_and_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    | logical_and_expression AND inclusive_or_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s&&%s</expr>", $1, $3);
    }
    ;
inclusive_or_expression: exclusive_or_expression {
        // printf("inclusive_or_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));

        sprintf($$, "%s", $1);
    }
    | inclusive_or_expression '|' exclusive_or_expression  {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s|%s</expr>", $1, $3);
    }
    ;
exclusive_or_expression: and_expression {
        // printf("exclusive_or_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | exclusive_or_expression '^' and_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s^%s</expr>", $1, $3);
    }
    ;
and_expression: equality_expression {
        // printf("and_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | and_expression '&' equality_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s&%s</expr>", $1, $3);
    }
    ;
equality_expression: relational_expression {
        // printf("equality_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | equality_expression EQUALS relational_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s==%s</expr>", $1, $3);
    }
    | equality_expression NOT_EQUALS relational_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s!=%s</expr>", $1, $3);
    }
    ;
relational_expression: shift_expression {
        // printf("relational_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | relational_expression '<' shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s<%s</expr>", $1, $3);
    }
    | relational_expression '>' shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s>%s</expr>", $1, $3);
    }
    | relational_expression LESS_OR_EQUAL shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s<=%s</expr>", $1, $3);
    }
    | relational_expression GREATER_OR_EQUAL shift_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s>=%s</expr>", $1, $3);
    }
    ;
shift_expression: additive_expression {
        // printf("shift_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | shift_expression LEFT_SHIFT additive_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s<<%s</expr>", $1, $3);
    }
    | shift_expression RIGHT_SHIFT additive_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s>>%s</expr>", $1, $3);
    }
    ;
additive_expression: multiplicative_expression {
        // printf("addi_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        //printf("<addi_expr>%s</addi_expr>\n", $1);
        sprintf($$, "%s", $1);
    }
    | additive_expression '+' multiplicative_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s+%s</expr>", $1, $3);
    }
    | additive_expression '-' multiplicative_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s-%s</expr>", $1, $3);
    }
    ;
multiplicative_expression: cast_expression {
        // printf("multi_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        //printf("<multi_expr>%s</multi_expr>\n", $1);
        sprintf($$, "%s", $1);
    }
    | multiplicative_expression '*' cast_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s*%s</expr>", $1, $3);
    }
    | multiplicative_expression '/' cast_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s/%s</expr>", $1, $3);
    }
    | multiplicative_expression '%' cast_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "<expr>%s%%%s</expr>", $1, $3);
    }
    ;
cast_expression: unary_expression {
        // printf("cast_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        //printf("<cast_expr>%s</cast_expr>\n", $1);
        sprintf($$, "%s", $1);
    }
    | '(' type_name ')' cast_expression {
        $$ = (char*)malloc((strlen($2) + strlen($4) + 20) * sizeof(char));
        sprintf($$, "<expr>(%s)%s</expr>", $2, $4);
    }
    ;
unary_expression: postfix_expression {
        // printf("unary_expr: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        //printf("<unary_expr>%s</unary_expr>\n", $1);
        sprintf($$, "%s", $1);
    }
    | unary_op cast_expression {
        // printf("unary_op: %s\n", $1);
        $$ = (char*)malloc((strlen($1) + strlen($2) + 20) * sizeof(char));
        //printf("<unary_expr>%s%s</unary_expr>\n", $1, $2);
        sprintf($$, "<expr>%s%s</expr>", $1, $2);
    }
    ;
postfix_expression: primary_expression {
        $$ = (char*)malloc((strlen($1) + 20)* sizeof(char));
        //printf("<postfix_expr>%s</postfix_expr>\n", $1);
        sprintf($$, "<expr>%s</expr>", $1);
    }
    | postfix_expression '(' ')' {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        //printf("<postfix_expr>%s()</postfix_expr>\n", $1);
        sprintf($$, "<expr>%s()</expr>", $1);
    }
    | postfix_expression '(' argument_expression_list ')'{
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        //printf("<postfix_expr>%s(%s)</postfix_expr>\n", $1, $3);
        sprintf($$, "<expr>%s(%s)</expr>", $1, $3);
    }
    | postfix_expression INC {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        //printf("<postfix_expr>%s++</postfix_expr>\n", $1);
        sprintf($$, "<expr>%s++</expr>", $1);
    }
    | postfix_expression DEC {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        //printf("<postfix_expr>%s--</postfix_expr>\n", $1);
        sprintf($$, "<expr>%s--</expr>", $1);
    }
    ;
argument_expression_list: assignment_expression {
        $$ = (char*)malloc((strlen($1) + 1)* sizeof(char));
        sprintf($$, "%s", $1);
    }
    | argument_expression_list ',' assignment_expression {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 2) * sizeof(char));
        sprintf($$, "%s,%s", $1, $3);
    }
    ;
primary_expression: IDENT {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        // sprintf($$, "%s", $1);
        sprintf($$, "%s", $1);
    }
    | primary_expression '[' expression ']' {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 20) * sizeof(char));
        sprintf($$, "%s[%s]", $1, $3);
    }
    | INTEGER {
        $$ = (char*)malloc((20) * sizeof(char) + sizeof(int));
        sprintf($$, "%d", $1);
    }
    | FLOATING {
        $$ = (char*)malloc((20) * sizeof(char) + sizeof(double));
        sprintf($$, "%f", $1);
    }
    | STRING {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | CHARACTER {
        $$ = (char*)malloc((strlen($1) + 20) * sizeof(char));
        sprintf($$, "%s", $1);
        // sprintf($$, "<expr>%s</expr>", $1);
    }
    | '(' expression ')' {
        $$ = (char*)malloc((strlen($2) + 20) * sizeof(char));
        sprintf($$, "(%s)", $2);
        // sprintf($$, "<expr>(%s)</expr>", $2);
    }
    ;
unary_op: '&' {sprintf($$, "%s", "&");}
    |'*' {sprintf($$, "%s", "*");}
    |'+' {sprintf($$, "%s", "+");}
    |'-' {sprintf($$, "%s", "-");}
    |'~' {sprintf($$, "%s", "~");}
    |'!' {sprintf($$, "%s", "!");}
    | INC {sprintf($$, "%s", "++");}
    | DEC {sprintf($$, "%s", "--");}
    ;
/* expression rules end */

/* additional events start */
type_name: type_list {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | type_list abstract_declarator {
        $$ = (char*)malloc((strlen($1) + strlen($2) + 10) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    ;
abstract_declarator: pointer {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | direct_abstract_declarator {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s", $1);
    }
    | pointer direct_abstract_declarator {
        $$ = (char*)malloc((strlen($1) + strlen($2) + 10) * sizeof(char));
        sprintf($$, "%s%s", $1, $2);
    }
    ;
direct_abstract_declarator: '(' abstract_declarator ')' {
        $$ = (char*)malloc((strlen($2) + 10) * sizeof(char));
        sprintf($$, "(%s)", $2);
    }
    | '[' ']' {
        $$ = (char*)malloc((10) * sizeof(char));
        sprintf($$, "%s", "[]");
    }
    | '[' expression ']' {
        $$ = (char*)malloc((strlen($2) + 10) * sizeof(char));
        sprintf($$, "[%s]", $2);
    }
    | direct_abstract_declarator '[' ']' {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s[]", $1);
    }
    | direct_abstract_declarator '[' expression ']' {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 10) * sizeof(char));
        sprintf($$, "%s[%s]", $1, $3);
    }
    | '(' ')' {
        $$ = (char*)malloc((10) * sizeof(char));
        sprintf($$, "%s", "()");
    }
    | '(' parameter_list ')' {
        $$ = (char*)malloc((strlen($2) + 10) * sizeof(char));
        sprintf($$, "[%s]", $2);
    }
    | direct_abstract_declarator '(' ')' {
        $$ = (char*)malloc((strlen($1) + 10) * sizeof(char));
        sprintf($$, "%s()", $1);
    }
    | direct_abstract_declarator '(' parameter_list ')' {
        $$ = (char*)malloc((strlen($1) + strlen($3) + 10) * sizeof(char));
        sprintf($$, "%s(%s)", $1, $3);
    }
    ;
/* additional events end */

%%

int main(){
    yyparse();
    return 0;
}
int yyerror(char *s){
    fprintf(stderr, "%s\n", s);
    return 0;
}
int yywrap(){
     return 1;
}
