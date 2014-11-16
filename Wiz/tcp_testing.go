//
// Tests TCP/IP connection bandwidth
//
// Usage: $ go run tcp_test.go
//

package main

import "net"
import "fmt"
import "bufio"
import "time"

const TEST_SIZE = 100000 // times 10 bytes

func main() {

    // connect
    conn, err := net.Dial("tcp", "192.168.1.250:5000")
    if err != nil {
        fmt.Printf("%s", err)
        return
    }

    // sending random strings with a goroutine
    go func() {
        for i := 0; i < TEST_SIZE; i++ {
            fmt.Fprintf(conn, "0123456789")
        }
    }()

    // receiving the strings
    var reader = bufio.NewReader(conn) 
    var total = 0
    var buf []byte = make([]byte, 256)
    var start_time = time.Now()
    for {
        l, err := reader.Read(buf)
        if err != nil {
            fmt.Printf("%s", err)
            return
        }
        if l == 0 || total >= TEST_SIZE {
            break
        }
        total += l
    }

    // disconnect
    conn.Close()

    // reporting
    elapsed_time := time.Now().Sub(start_time)
    fmt.Printf("processed %d bytes at %.2f Mbps\n", total * 10, float64(total * 10 * 8) / float64(elapsed_time.Seconds() * 1000000)) 
}
