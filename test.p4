#include <core.p4>
#include <tna.p4>

struct headers {
}
struct metadata {
}

parser MyParser(packet_in pkt, out headers hdr, 
                out metadata meta, 
                out ingress_intrinsic_metadata_t ig_intr_md) {
    state start {
        transition accept;
    }
};

control MyVerifyChecksum(inout headers hdr, inout metadata meta,
                         in ingress_intrinsic_metadata_t ig_intr_md) {
    apply {
    }
};

control MyIngress(inout headers hdr, inout metadata meta,
                  in ingress_intrinsic_metadata_t ig_intr_md, 
                  in ingress_intrinsic_metadata_from_parser_t ig_intr_prsr_md,
                  inout ingress_intrinsic_metadata_for_deparser_t ig_intr_dprsr_md,
                  inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    apply {
    }
};

control MyEgress(inout headers hdr, inout metadata meta,
                 in egress_intrinsic_metadata_t eg_intr_md,
                 in egress_intrinsic_metadata_from_parser_t eg_intr_md_from_prsr,
                 inout egress_intrinsic_metadata_for_deparser_t eg_intr_dprs_md,
                 inout egress_intrinsic_metadata_for_output_port_t eg_intr_oport_md) {
    apply {
    }
};

control MyComputeChecksum(inout headers hdr, inout metadata meta, 
                          in egress_intrinsic_metadata_t eg_intr_md) {
    apply {
    }
};

control MyDeparser(packet_out pkt, in headers hdr,
                   in ingress_intrinsic_metadata_for_deparser_t ig_intr_dprsr_md) {
    apply {
    }
};

Pipeline(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(), 
    MyComputeChecksum(),
    MyDeparser()) TofinoNativeArchitecture;

Switch(TofinoNativeArchitecture) main;
