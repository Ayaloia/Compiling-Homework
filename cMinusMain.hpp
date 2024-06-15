#ifndef _CMINUSMAIN_HPP_
#define _CMINUSMAIN_HPP_

#include <string>
#include <vector>
using namespace std;

enum nodeType
{
    semantic,
    id,
    intType,
    floatType,
    intVal,
    floatVal,
    other,
};

union nodeVal
{
    string *id;
    int intVal;
    float floatVal;
};

struct node
{
    nodeType type;
    const char *word;
    nodeVal val;
    vector<node *> sons;
    node() : sons{}, type(nodeType::other), val() {}
    node(nodeType type, const char *word) : sons{}, type(type), word(word) {}
    node(nodeType type, const char *word, int val) : sons{}, type(type), word(word)
    {
        this->val.intVal = val;
    }
    node(nodeType type, const char *word, float val) : sons{}, type(type), word(word)
    {
        this->val.floatVal = val;
    }
    node(nodeType type, const char *word, string *val) : sons{}, type(type), word(word)
    {
        this->val.id = val;
    }
};

void inline setNode(node *&theNode, const char *word, int line)
{
    theNode = new node(nodeType::semantic, word, line);
    return;
}

template <typename T>
void inline setTNode(node *&theNode, const char *word, T val, nodeType type)
{
    theNode = new node(type, word, val);
}

void inline setTNode(node *&theNode, const char *word, nodeType type)
{
    theNode = new node(type, word);
}

#endif // _CMINUSMAIN_HPP_
