#include <tna.p4>

struct metadata { }
struct headers { }

parser MyParser(packet_in p, out headers h, inout metadata m, in pna_main_parser_input_metadata_t i) {
    state start { transition accept; }
}

control MyIngress(inout headers h, inout metadata m, inout pna_main_input_metadata_t i, inout pna_main_output_metadata_t o) {
    apply { o.egress_spec = 1; }
}

control MyEgress(inout headers h, inout metadata m, inout pna_main_input_metadata_t i, inout pna_main_output_metadata_t o) {
    apply { }
}

control MyDeparser(packet_out p, in headers h) {
    apply { }
}

control MyVerifyChecksum(inout headers h, inout metadata m) {
    apply { }
}

control MyComputeChecksum(inout headers h, inout metadata m) {
    apply { }
}

MainTNA(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(), 
    MyComputeChecksum(),
    MyDeparser()
) main;
