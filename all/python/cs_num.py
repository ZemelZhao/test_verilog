
def list2str0(data):
    res = ''
    for i in range(len(data)):
        res += hex(data[i])[2:].upper().rjust(2, '0')
    res = res.ljust(16, '0')
    return res


def list2str1(data):
    res = ''
    for i in range(len(data)):
        res += str(data[i])
    res = res.ljust(8, '0')
    res = hex(int('0b'+res, 2))[2:].upper().zfill(2)
    return res

def test(width):
    res = width * "\t"
    res += "case(cmd_kdev)\n"
    for i in range(256):
        res += wr(i, width)
    res += width * "\t"
    res += "endcase"
    return res


def wr(num, width):
    r0, r1, r2, r3 = cal(num)
    cmd, ind, lrt, vtb, end = cal1(num)
    res = (width + 1) * "\t"
    res += "8'h%s: begin\n" % r0
    res += (width + 2)*"\t"
    res += "adc_rx_len <= 10'h%s;\n" % r1
    res += (width + 2)*"\t"
    res += "eth_tx_len <= 12'h%s;\n" % r2
    res += (width + 2)*"\t"
    res += "data_cnt <= 8'h%s;\n" % r3
    res += (width + 2)*"\t"
    res += "intan_cmd <= 64'h%s;\n" % cmd
    res += (width + 2)*"\t"
    res += "intan_ind <= 64'h%s;\n" % ind
    res += (width + 2)*"\t"
    res += "intan_lrt <= 8'h%s;\n" % lrt
    res += (width + 2)*"\t"
    res += "intan_vtb <= 8'h%s;\n" % vtb
    res += (width + 2)*"\t"
    res += "intan_end <= 8'h%s;\n" % end
    res += (width + 1)*"\t"
    res += "end\n"
    return res

    
def cal1(num):
    tmp = bin(num)[2:].zfill(8)
    list_cmd = []
    list_ind = []
    list_lrt = []
    list_end = []
    list_vtb = []
    for i in range(4):
        num = tmp[i*2: i*2+2]
        if num == '01':
            list_cmd.append(1 << (7-2*i))
            list_ind.append(63 - 16*i)
            list_lrt.append(0)
            list_end.append(0)
            list_vtb.append(1)
        elif num == '10':
            list_cmd.append(1 << (7-2*i))
            list_ind.append(63 - 16*i)
            list_lrt.append(1)
            list_end.append(0)
            list_vtb.append(1)
        elif num == '11':
            list_cmd.append(1 << (7-2*i))
            list_cmd.append(1 << (6-2*i))
            list_ind.append(63 - 16*i)
            list_ind.append(55 - 16*i)
            list_lrt.append(1)
            list_lrt.append(1)
            list_end.append(0)
            list_end.append(0)
            list_vtb.append(0)
            list_vtb.append(1)
        else:
            pass
    if len(list_end):
        list_end[-1] = 1
    cmd = list2str0(list_cmd)
    ind = list2str0(list_ind)
    lrt = list2str1(list_lrt)
    end = list2str1(list_end)
    vtb = list2str1(list_vtb)

    return cmd, ind, lrt, vtb, end


def cal(num):
    res = (hex(num)[2:]).upper().zfill(2)
    tmp = bin(num)[2:].zfill(8)
    r0 = 6
    for i in range(4):
        num = tmp[i*2 : i*2 + 2]
        if num == '00':
            r0 += 0
        elif num == '01':
            r0 += 32
        elif num == '10':
            r0 += 64
        elif num == '11':
            r0 += 128
        else:
            r0 += 0
    res0 = (hex(r0)[2:]).upper().zfill(3)
    tmp = 1472 // r0
    if tmp >= 10:
        res2 = 10
    else:
        res2 = tmp
    res1 = res2 * r0
    res1 = (hex(res1)[2:]).upper().zfill(3)
    res2 = (hex(res2)[2:]).upper().zfill(2)
    return (res, res0, res1, res2)

def main(w):
    tmp = test(w)
    with open('cs_num.v', 'w') as f:
        f.write(tmp)




if __name__ == '__main__':
    main(3)
    print('Done')

