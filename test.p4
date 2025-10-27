#include <core.p4>
#include <tna.p4>

// No actual headeers (just for test)
struct headers {
    bit<1> dummy; // dummy format (just for test)
}

// Data format which will be processed by the Tofino
struct metadata {
    bit<1> dummy_meta; // dummy format (just for test)
}

// Not extracting any headers from the package (jsut testing, passing the package to "accept")
parser MyIngressParser(
    packet_in pkt,
    out headers ig_hdr,
    out metadata ig_md,
    out ingress_intrinsic_metadata_t ig_intr_md)
{
    
    state start {
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);
        transition parse_ethernet;
    }
    
    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select (hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4 : parse_ipv4;
            default : accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition select (hdr.ipv4.protocol) {
	    IP_PROTOCOLS_TCP : parse_tcp;
	    IP_PROTOCOLS_UDP : parse_udp;
	    default : accept;
    	}
    }

    state parse_tcp {
	pkt.extract(hdr.tcp);
        transition accept;
    }
 
    state parse_udp {
	pkt.extract(hdr.udp);
        transition accept;
    }
    
};

// No forwarding table being applied (again, just testing) and no actions are being executed
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

// Sends directly to the traffic manager, not apllying any serial action
control MyIngressDeparser(
    packet_out pkt,
    inout headers ig_hdr,
    in metadata ig_md,
    in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md)
{
    apply {
    }
};

// Again, no headers are extracted, just passing to acceptt
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

// Doesn't write anything in the headers
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

// DOESN'T FORWARD THE PACKAGE THROUGHOUT AN EXIT PORT (JUST TESTING)
control MyEgressDeparser(
    packet_out pkt,
    inout headers eg_hdr,
    in metadata eg_md,
    in egress_intrinsic_metadata_for_deparser_t eg_dprsr_md)
{
    apply {
    }
};

// defines the processing flow
Pipeline(
    MyIngressParser(),
    MyIngress(),
    MyIngressDeparser(),
    MyEgressParser(),
    MyEgress(),
    MyEgressDeparser()) pipe;

Switch(pipe) main;
