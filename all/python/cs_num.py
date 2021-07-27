

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
    res = (width + 1) * "\t"
    res += "8'h%s: begin\n" % r0
    res += (width + 2)*"\t"
    res += "adc_rx_len <= 10'h%s;\n" % r1
    res += (width + 2)*"\t"
    res += "eth_tx_len <= 12'h%s;\n" % r2
    res += (width + 2)*"\t"
    res += "data_cnt <= 8'h%s;\n" % r3
    res += (width + 1)*"\t"
    res += "end\n"
    return res


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

