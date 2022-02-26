#include<bits/stdc++.h>
using namespace std;
extern FILE* logtext;

class SymbolInfo
{
    string Name;
    string Type;
public:
    SymbolInfo * chain;
    string tt;

    SymbolInfo(string x, string y)
    {
        Name=x;
        Type=y;
        chain=NULL;
    }
    void setName(string x)
    {
        Name=x;
    }
    void setType(string x)
    {
        Type=x;
    }
    string getName()
    {
        return Name;
    }
    void setchain(SymbolInfo * element)
    {
        chain=element;
    }
    string getType()
    {
        return Type;
    }
    SymbolInfo * getchain()
    {
        return chain;
    }

};


class ScopeTable
{
    SymbolInfo **point;
    int serial;
    int h_size;
public:
    ScopeTable * parentScope;

    ScopeTable(int n, ScopeTable * parent, int no)
    {
        parentScope=parent;
        point=new SymbolInfo* [n];
        int i;
        for(i=0; i<n; i++)
        {
            point[i]=nullptr;
        }
        serial=no;
        h_size=n;
    } 

    int Hashing(string x)
    {
    int Sum = 0;
    int i;
    for (i = 0; i < x.length(); i++)
    {
        Sum=Sum + x[i];
    }

    return (Sum % h_size);
    }

SymbolInfo* Lookup(string x)
{
    int position = Hashing(x);
    int k=0;

    SymbolInfo* ptr = point[position];
    while(ptr)
    {
	if(ptr->getName() == x)
	{
	    cout<<" Found in ScopeTable# "<<serial<<" at position "<<position<<",        "<<k<<endl;
	    return ptr;
	}
	k++;
	ptr = ptr->getchain();
    }

    cout<<x<<" not found"<<endl;
    return nullptr;
}

bool Insert(string m, string n)
{
    
    string name = m;
    if(Lookup(name))
    {
       cout<<name<<" already exists in the current scope table "<<endl;
        return false;
    }

    int position = Hashing(name);
    SymbolInfo* ptr = point[position];
    if(!ptr)
    {
        point[position] = new SymbolInfo(m, n);
        cout<<" Inserted in ScopeTable# "<<serial<<" at position "<<position<<", 0"<<endl;
    }
    else
    {
        int k=1;
        while(ptr->getchain())
        {
            k++;
            ptr = ptr->getchain();
        }
        SymbolInfo* current = new SymbolInfo(m, n);
        ptr->setchain(current);
        cout<<" Inserted in ScopeTable# "<<serial<<" at position "<<position<<", "<<k<<endl;
    }

    return true;
}

bool Delete(string x)
{
    int position = Hashing(x);

    SymbolInfo *ptr = point[position];
    SymbolInfo *prev = nullptr;

    int counter = 0;
    while(ptr)
    {
        if(ptr->getName() == x)
        {
            cout << "Found in ScopeTable #" << serial << " at position  " << position << " ," << counter << "\n";
            cout << "Deleted entry at " << position << " ," << counter <<"from current scopetable"<< "\n";
            if(!prev)
            {
                point[position] = ptr->getchain();
            }
            else
            {
                prev->setchain(ptr->getchain());
            }
            delete ptr;
            return true;
        }

        ++counter;
        prev = ptr;
        ptr = ptr->getchain();
    }
    cout<<x<<"  not found"<<endl;
    return false;
}

void PrintTable()
{
    cout << "ScopeTable # " << serial << "\n";
    fprintf(logtext,"ScopeTable # %d\n",serial );
    for(int i=0; i<h_size; i++)
    {
        cout << i << " --> ";
        fprintf(logtext,"%d -->",i);
        SymbolInfo *ptr = point[i];
        while(ptr)
        {
            cout << "< " << ptr->getName() << " : " << ptr->getType() << " > ";
            fprintf(logtext,"<%s : %s>",ptr->getName().c_str(), ptr->getType().c_str() );
            ptr = ptr->getchain();
        }
        cout << "\n";
        fprintf(logtext,"\n");
    }
}

    int getserial()
    {
        return serial;
    }

    ~ScopeTable()
    {
        //delete(parentScope);
        int k;
        for(k=0;k<h_size;k++)
        {
            delete(point[k]);
        }
        delete[] point;
    }
};


class SymbolTable
{
    
    int h_size;
  

public:
    ScopeTable *cur_scope;
    int cnt;
    SymbolTable(int h_size)
    {
        this->h_size = h_size;
	this->cnt = 0;
        cur_scope = new ScopeTable(h_size, nullptr, ++cnt);
    }

    void enter_scope()
    {
        ScopeTable *new_scope = new ScopeTable(h_size, cur_scope, ++cnt);
        cur_scope = new_scope;
        cout<<" New ScopeTable with id "<<cur_scope->getserial()<<" created"<<endl;
        fprintf(logtext," New ScopeTable with id %d created\n",cur_scope->getserial());
    }

    void exit_scope()
    {
        if(cur_scope == nullptr)
        {
            cout<<"No scope table found"<<endl;
            return;
        }
        ScopeTable *temp_ptr = cur_scope;
        cur_scope = cur_scope->parentScope;
        cout<<"ScopeTable with id "<<temp_ptr->getserial()<<" removed"<<endl;
        fprintf(logtext," ScopeTable with id %d removed\n",temp_ptr->getserial());
        delete temp_ptr ;
    }

    bool insert(string m, string n)
    {
        return cur_scope->Insert(m,n);
    }

    bool remove(string x)
    {
        return cur_scope->Delete(x);
    }

    SymbolInfo* lookup(string x)
    {
        ScopeTable *ptr = cur_scope;
        while(ptr)
        {
            SymbolInfo *res = ptr->Lookup(x);
            if(res)
                return res;
            ptr = ptr->parentScope;
        }
        //cout<<" not found "<<endl;
        return nullptr;
    }

    void printCurrentScope()
    {
        cur_scope->PrintTable();
    }

    void printAllScopes()
    {
        ScopeTable *ptr = cur_scope;
        while(ptr)
        {
            ptr->PrintTable();
            ptr = ptr->parentScope;
        }
         fprintf(logtext,"\n\n");
    }
};


