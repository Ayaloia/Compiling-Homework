%union {
    struct node* node;
}

%{
    #include<cMinusMain.hpp>
    extern struct node* root;
    extern int yylineno;
    extern int yylex (void);
    extern bool isSuccess;
    void yyerror (char const *s);
%}

%token <node> INT
%token <node> FLOAT
%token <node> ID

%right <node> ASSIGNOP
%left <node> OR
%left <node> AND
%left <node> RELOP
%left <node> PLUS MINUS
%left <node> STAR DIV
%right <node> NOT
%left <node> LP RP LB RB DOT

%precedence <node> ELSE
%token <node> STRUCT RETURN IF WHILE SEMI COMMA TYPE LC RC

%type <node> Program ExtDefList ExtDef ExtDecList Specifier
    StructSpecifier OptTag Tag VarDec FunDec VarList ParamDec
    CompSt StmtList Stmt DefList Def DecList Dec Exp Args

%%

Program
    : ExtDefList {
        setNode($$, "Program", yylineno);
        $$->sons.emplace_back($1);
        root = $$;
    }
    ;
ExtDefList
    : ExtDef ExtDefList {
        setNode($$, "ExtDefList", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
    }
    | %empty { setNode($$, "ExtDefList", yylineno); }
    ;
ExtDef
    : Specifier ExtDecList SEMI {
        setNode($$, "ExtDef", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Specifier SEMI {
        setNode($$, "ExtDef", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
    }
    | Specifier FunDec CompSt {
        setNode($$, "ExtDef", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    ;
ExtDecList
    : VarDec {
        setNode($$, "ExtDecList", yylineno);
        $$->sons.emplace_back($1);
    }
    | VarDec COMMA ExtDecList {
        setNode($$, "ExtDecList", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    ;

Specifier
    : TYPE {
        setNode($$, "Specifier", yylineno);
        $$->sons.emplace_back($1);
    }
    | StructSpecifier {
        setNode($$, "Specifier", yylineno);
        $$->sons.emplace_back($1);
    }
    ;
StructSpecifier
    : STRUCT OptTag LC DefList RC {
        setNode($$, "StructSpecifier", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        $$->sons.emplace_back($5);
    }
    | STRUCT Tag {
        setNode($$, "StructSpecifier", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
    }
    ;
OptTag
    : ID {
        setNode($$, "OptTag", yylineno);
        $$->sons.emplace_back($1);
    }
    | %empty { setNode($$, "OptTag", yylineno); }
    ;
Tag
    : ID {
        setNode($$, "Tag", yylineno);
        $$->sons.emplace_back($1);
    }
    ;

VarDec
    : ID {
        setNode($$, "VarDec", yylineno);
        $$->sons.emplace_back($1);
    }
    | VarDec LB INT RB {
        setNode($$, "VarDec", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
    }
    ;
FunDec
    : ID LP VarList RP {
        setNode($$, "FunDec", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
    }
    | ID LP RP {
        setNode($$, "FunDec", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    ;
VarList
    : ParamDec COMMA VarList {
        setNode($$, "VarList", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | ParamDec {
        setNode($$, "VarList", yylineno);
        $$->sons.emplace_back($1);
    }
    ;
ParamDec
    : Specifier VarDec {
        setNode($$, "ParamDec", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
    }
    ;

CompSt
    : LC DefList StmtList RC {
        setNode($$, "CompSt", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
    }
    ;
StmtList
    : Stmt StmtList {
        setNode($$, "StmtList", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
    }
    | %empty { setNode($$, "StmtList", yylineno); }
    ;
Stmt
    : Exp SEMI {
        setNode($$, "Stmt", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
    }
    | CompSt {
        setNode($$, "Stmt", yylineno);
        $$->sons.emplace_back($1);
    }
    | RETURN Exp SEMI {
        setNode($$, "Stmt", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | IF LP Exp RP Stmt {
        setNode($$, "Stmt", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        $$->sons.emplace_back($5);
    }
    | IF LP Exp RP Stmt ELSE Stmt {
        setNode($$, "Stmt", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        $$->sons.emplace_back($5);
        $$->sons.emplace_back($6);
        $$->sons.emplace_back($7);
    }
    | WHILE LP Exp RP Stmt {
        setNode($$, "Stmt", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
        $$->sons.emplace_back($5);
    }
    ;

DefList
    : Def DefList {
        setNode($$, "DefList", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
    }
    | %empty { setNode($$, "DefList", yylineno); }
    ;
Def
    : Specifier DecList SEMI {
        setNode($$, "Def", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    ;
DecList
    : Dec {
        setNode($$, "DecList", yylineno);
        $$->sons.emplace_back($1);
    }
    | Dec COMMA DecList {
        setNode($$, "DecList", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    ;
Dec
    : VarDec {
        setNode($$, "Dec", yylineno);
        $$->sons.emplace_back($1);
    }
    | VarDec ASSIGNOP Exp {
        setNode($$, "Dec", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    ;

Exp
    :Exp ASSIGNOP Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Exp AND Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Exp OR Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Exp RELOP Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Exp PLUS Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Exp MINUS Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Exp STAR Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Exp DIV Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | LP Exp RP {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | MINUS Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
    }
    | NOT Exp {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
    }
    | ID LP Args RP {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
    }
    | ID LP RP {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Exp LB Exp RB {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
        $$->sons.emplace_back($4);
    }
    | Exp DOT ID {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | ID {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
    }
    | INT {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
    }
    | FLOAT {
        setNode($$, "Exp", yylineno);
        $$->sons.emplace_back($1);
    }
    ;
Args
    : Exp COMMA Args {
        setNode($$, "Args", yylineno);
        $$->sons.emplace_back($1);
        $$->sons.emplace_back($2);
        $$->sons.emplace_back($3);
    }
    | Exp {
        setNode($$, "Args", yylineno);
        $$->sons.emplace_back($1);
    }
    ;

%%

void yyerror (char const *s)
{
    isSuccess = false;
    printf("Error type B at Line %d: %s\n", yylineno, s);
}
