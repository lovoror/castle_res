import os
import os.path
import sys
import xlrd
import json

excleFilePath = "items.xlsm";
exportFilePath = "";

if (exportFilePath == ""):
    name, ext = os.path.splitext(excleFilePath);
    exportFilePath = name + ".json";


    

class BaseExcleExporter:
    def __init__(self):{}
    def read(self, excle):{}
    def finish(self):{}


    

class JsonExcleExporter(BaseExcleExporter):
    valuesType = [];
    keys = [];
    jsonData = [];
    
    def read(self, excle):
        table = excle.sheets()[0];
        numRows = table.nrows;
        numCols = table.ncols;
        for r in range(numRows):
            rowCells = table.row(r);
            if r == 1:
                for c in range(numCols):
                    self.valuesType.append(rowCells[c].value);
            elif r == 2:
                for c in range(numCols):
                    self.keys.append(rowCells[c].value);
            elif r > 2:
                obj = {};
                numElements = 0;
                for c in range(numCols):
                    if self.valuesType[c] != "helper":
                        cell = rowCells[c];
                        value = cell.value;
                        if cell.ctype != xlrd.XL_CELL_EMPTY and value != "":
                            jsonValue = None;
                            valueType = self.valuesType[c];
                            valueTypeLen = len(valueType);
                            isArray = 0;
                            if valueTypeLen >= 2 and valueType[valueTypeLen - 2 : valueTypeLen] == "[]":
                                isArray = 1;
                                valueType = valueType[0 : valueTypeLen - 2];

                            jsonValue = self.convertCellValue(cell.ctype, cell.value, valueType, isArray);

                            if jsonValue != None:
                                numElements += 1;
                                obj[self.keys[c]] = jsonValue;

                if numElements > 0:
                    self.jsonData.append(obj);

    def convertCellValue(self, cellType, cellValue, toType, isArray):
        if isArray == 1:
            values = str(cellValue).split(',');
            valuesLen = len(values);
            arr = [];
            for i in range(valuesLen):
                value = self.convertCellValue(xlrd.XL_CELL_TEXT, values[i].strip(), toType, 0);
                if value != None:
                    arr.append(value);

            if len(arr) == 0:
                return None;
            else:
                return arr;
        else:
            if toType == "string":
                if cellType == xlrd.XL_CELL_TEXT:
                    return cellValue;
                elif cellType == xlrd.XL_CELL_NUMBER:
                    return str(int(cellValue));
                else:
                    return None;
            elif toType == "number":
                return float(cellValue);
            elif toType == "int":
                return int(float(cellValue));
            else:
                return None;
                    
    def finish(self):
        fout = open(exportFilePath, 'bw');
        outStr = json.dumps(self.jsonData, ensure_ascii = False);
        fout.write(outStr.strip().encode('utf-8'));
        fout.close();


        

exporter = JsonExcleExporter();
exporter.read(xlrd.open_workbook(excleFilePath));
exporter.finish();
print("finish : " + exportFilePath);
