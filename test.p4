#include <tna.p4>

struct headers {
    bit<1> dummy; 
}

struct metadata {
    bit<1> dummy_meta;
}

parser MyIngressParser(
    packet_in pkt,
    out headers ig_hdr,
    out metadata ig_md,
    out ingress_intrinsic_metadata_t ig_intr_md)
{
    state start {
        transition accept;
    }
};

control MyIngress(
    inout headers ig_hdr,
    inout metadata ig_md,
    in ingress_intrinsic_metadata_t ig_intr_md,
    in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md)
{
    apply {
    }
};

control MyIngressDeparser(
    packet_out pkt,
    inout headers ig_hdr,
    in metadata ig_md,
    in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md)
{
    apply {
    }
};

parser MyEgressParser(
    packet_in pkt,
    out headers eg_hdr,
    out metadata eg_md,
    out egress_intrinsic_metadata_t eg_intr_md)
{
    state start {
        transition accept;
    }
};

control MyEgress(
    inout headers eg_hdr,
    inout metadata eg_md,
    in egress_intrinsic_metadata_t eg_intr_md,
    in egress_intrinsic_metadata_from_parser_t eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t eg_oport_md)
{
    apply {
    }
};

control MyEgressDeparser(
    packet_out pkt,
    inout headers eg_hdr,
    in metadata eg_md,
    in egress_intrinsic_metadata_for_deparser_t eg_dprsr_md)
{
    apply {
    }
};

Pipeline(
    MyIngressParser(),
    MyIngress(),
    MyIngressDeparser(),
    MyEgressParser(),
    MyEgress(),
    MyEgressDeparser()) pipe;

Switch(pipe) main;
