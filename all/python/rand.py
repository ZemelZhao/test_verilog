'''
Author: your name
Date: 2021-09-18 23:19:40
LastEditTime: 2021-09-19 21:55:22
LastEditors: Please set LastEditors
Description: In User Settings Edit
FilePath: /test_verilog/all/python/rand.py
'''
import numpy as np

def randnum():
    num = np.random.randint(65536)
    res = (hex(num)[2:]).zfill(4).upper()
    return res

def veriog_localparam_arrange(data, num):
    res = ""
    for i in range(len(data)):
        if i%num == 0:
            res += 'localparam '
        res += data[i]
        if i%num == (num-1) or i == len(data) -1:
            res += ';\n'
        else:
            res += ', '
    return res

def verilog_localparam_name(name, num, length):
    list_res = []
    for i in range(length):
        nam = (hex(i)[2:]).zfill(2).upper()
        ndt = (hex(i+num)[2:]).zfill(2).upper()
        list_res.append("%s%s = 8'h%s" % (name, nam, ndt))
    return list_res

def verilog_variable_name(name, length):
    list_res = []
    for i in range(length):
        nam = (hex(i)[2:]).zfill(2).upper()
        list_res.append("%s%s" % (name, nam))
    return list_res


def verilog_case_arrange(name, data):
    res = ""
    judge = (type(data[0]) == type([1]))
    for i in range(len(name)):
        res += "%s:" % name[i]
        if judge:
            res += " begin\n"
            for j in range(len(data)):
                res += "\t%s;\n" % data[j][i]
            res += "end\n"
        else:
            res += "%s;\n" % data[i]
    return res

def test(list_name):
    res = []
    tmp = list_name[1:]
    tmp.append("FIST")
    for i in range(len(list_name)):
        res.append("state_goto <= %s" % tmp[i])
    return res

def tes():
    res0 = []
    res1 = []
    dat0 = verilog_variable_name("D0", 34)
    dat1 = verilog_variable_name("D1", 34)
    for i in range(34):
        res0.append("chip_rxd0 <= %s" % dat0[i])
        res1.append("chip_rxd1 <= %s" % dat1[i])
    return res0, res1

def te():
    res = []
    for i in range(34):
        res.append("{fs0, fs1} <= 2'b11")
    return res
        

def verilog_ifstate_arrange(name, data):
    res = ""
    judge = (type(data[0]) == type([1]))
    for i in range(len(name)):
        res += "else if(state == %s) " % name[i]
        if judge:
            res += "begin\n"
            for j in range(len(data)):
                res += "\t%s;\n" % data[j][i]
            res += "end\n"
        else:
            res += "%s;\n" % data[i]
    return res

def verilog_write_file(data, num):
    res = ""
    tmp = data.split("\n")
    for i in range(len(tmp)):
        tmp[i] = num*"\t" + tmp[i] + "\n"
        res += tmp[i]
    return res



        


            

def main():
    list_name = verilog_variable_name("TX", 34)
    dat0 = test(list_name)
    dat1, dat2 = tes()
    dat3 = te()
    list_dat = [dat0, dat1, dat2, dat3]
    res = verilog_ifstate_arrange(list_name, list_dat)
    res = verilog_write_file(res, 2)
    
    with open("rand.txt", "w") as f:
        f.write(res)

        
    

        
                
            

if __name__ == '__main__':
    main()

        



