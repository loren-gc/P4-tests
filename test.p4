#include <tna.p4>

struct metadata {
}

struct headers {
}

parser MyParser(packet_in packet, out headers hdr, inout metadata meta) {
    state start {
        transition accept;
    }
}

control MyIngress(inout headers hdr, inout metadata meta) {
    action set_egress_port(bit<9> port) {
        standard_metadata.egress_spec = port;
    }
    
    apply {
        set_egress_port(1);
    }
}

control MyEgress(inout headers hdr, inout metadata meta) {
    apply {
    }
}

control MyDeparser(packet_out packet, in headers hdr) {
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

TofinoNativeArchitecture(
    MyParser(),
    MyVerifyChecksum(), 
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
