#include <tna.p4>

struct metadata {
}

struct headers {
}

parser MyParser(packet_in pkt, out headers hdr, inout metadata meta) {
    state start {
        transition accept;
    }
}

control MyIngress(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control MyEgress(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control MyDeparser(packet_out pkt, in headers hdr) {
    apply {
    }
}

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

// Versão mais simples - apenas instanciando diretamente
//TofinoNativeArchitecture(
//    MyParser(),
//    MyVerifyChecksum(),
//    MyIngress(),
//    MyEgress(), 
//    MyComputeChecksum(),
//    MyDeparser()
//) main;
