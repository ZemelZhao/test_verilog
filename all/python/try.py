'''
Author: your name
Date: 2021-07-30 21:47:12
LastEditTime: 2021-07-30 21:55:30
LastEditors: Please set LastEditors
Description: In User Settings Edit
FilePath: /test_verilog/all/python/try.py
'''


def try0(num):
    tmp = bin(num)[2:].zfill(8)
    return tmp
    

def main():
    a = try0(3)
    print(a)
    


if __name__ == '__main__':
     main()




    