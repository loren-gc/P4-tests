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

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
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

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control MyDeparser(packet_out pkt, in headers hdr) {
    apply {
    }
}

TofinoNativeArchitecture(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(), 
    MyComputeChecksum(),
    MyDeparser()
) main;
