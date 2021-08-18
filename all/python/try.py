'''
Author: your name
Date: 2021-07-30 21:47:12
LastEditTime: 2021-08-17 21:51:14
LastEditors: Please set LastEditors
Description: In User Settings Edit
FilePath: /test_verilog/all/python/try.py
'''

def main():
    lt = []
    dat = ""
    for i in range(64):
        t0 = i // 2
        if i % 2:
            t1 = 'L'
        else:
            t1 = 'H'
        lt.append("D%02d%s" % (t0, t1))
    for i in range(63):
        dat += "\t\t%s: next_state <= %s;\n" % (lt[i], lt[i+1])
    print(dat)
        

if __name__ == '__main__':
     main()




    