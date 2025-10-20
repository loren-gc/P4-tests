#include <tna.p4>

struct metadata {
    // Metadados vazios
}

struct headers {
    // Cabeçalhos vazios - programa mínimo
}

parser MyParser(packet_in p, out headers h, inout metadata m, in standard_metadata_t s) {
    state start { transition accept; }
}

control MyIngress(inout headers h, inout metadata m, inout standard_metadata_t s) {
    apply { }
}

control MyEgress(inout headers h, inout metadata m, inout standard_metadata_t s) {
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

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
