#include <cMinusMain.hpp>
#include <cMinus.tab.h>
#include <stdio.h>

node *root = nullptr;
extern FILE *yyin;
bool isSuccess;

void printNode(node *x, int level = 0)
{
    if (x == nullptr)
        return;

    for (int i = 0; i < level; i++)
        printf("  ");
    printf("%s", x->word);

    switch (x->type)
    {
    case nodeType::semantic:
        printf(" (%d)\n", x->line);
        break;
    case nodeType::id:
        printf(": %s\n", x->val.id->c_str());
        break;
    case nodeType::intType:
        printf(": int\n");
        break;
    case nodeType::floatType:
        printf(": float\n");
        break;
    case nodeType::intVal:
        printf(": %d\n", x->val.intVal);
        break;
    case nodeType::floatVal:
        printf(": %g\n", x->val.floatVal);
        break;
    case nodeType::other:
        puts("");
        break;
    default:
        break;
    }
    for (auto i : x->sons)
    {
        printNode(i, level + 1);
    }
}

int main(int argc, char **argv)
{
    const char *fileName;
    isSuccess = true;
#ifdef C_MINUS_FILE_IO
    freopen("text1.out", "w", stdout);
#endif // C_MINUS_FILE_IO

    if (argc < 2)
    {
#ifdef C_MINUS_FILE_IO
        fileName = "text1.in";
#else
        puts("Usage: ./cminus <filename>");
        return 0;
#endif // C_MINUS_FILE_IO
    }
    else
        fileName = argv[1];
    yyin = fopen(fileName, "r");
    if (!yyin)
        return 0;
    yyparse();
    fclose(yyin);

    if (isSuccess)
        printNode(root);

    return 0;
}
