import os
import os.path
import sys

#rootDir = "C:/Users/Sephiroth/Documents/Projects/Castle/res";
#rootDir = "E:/Work/Castle/res";
rootDir = os.getcwd() + "/../";
keyword = "CESSpriteRefBox.setActionListener";
replace = "";

findNum = 0;
replaceNum = 0;
for parent,dirnames,filenames in os.walk(rootDir):
    #case 1:
    #for dirname in dirnames:  
        #print("parent folder is:" + parent)
        #print("dirname is:" + dirname)
    #case 2:
    for filename in filenames:
        #print("parent folder is:" + parent)
        f,ext = os.path.splitext(filename);
        #print( " f is: " + f)
        #print( " ext is:" + ext)
        if ext == ".lua":
            path = os.path.join(parent, filename);
            text = "";
            file = open(path, 'r', encoding = 'utf-8');
            try:
                text = file.read();
            except:
                print("error : " + path);
            finally:
                file.close();

            if replace != "" and text.find(keyword) != -1:
                replaceNum += 1;
                text = text.replace(keyword, replace);
                file = open(path, 'w');
                file.write(text);
                file.close();
                print("replace file path:" + path);
                
            lines = text.split('\n');
            curLines = 0;
            for line in lines:
                curLines += 1;
                pos = line.find(keyword);
                if pos != -1:
                    findNum += 1;
                    print("find file path:" + path);
                    print("line (" + str(curLines) + ") : " + line);
                    print("\n");

print("find num : " + str(findNum) + "   replace num : " + str(replaceNum));
          
