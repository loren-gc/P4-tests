#include <core.p4>
#include <t2na.p4>
#include "headers.p4"

// Handling TCP and UDP packages
parser MyIngressParser(
    packet_in pkt,
    out headers_t ig_hdr,
    out metadata_t ig_md,
    out ingress_intrinsic_metadata_t ig_intr_md)
{
    
    state start {
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);
        transition parse_ethernet;
    }
    
    state parse_ethernet {
        pkt.extract(ig_hdr.ethernet);
        transition select (ig_hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4 : parse_ipv4;
            default : accept; // If it's not ipv4, just accept the package
        }
    }

    state parse_ipv4 {
        pkt.extract(ig_hdr.ipv4);
        transition select (ig_hdr.ipv4.protocol) {
	    IP_PROTOCOLS_TCP : parse_tcp;
	    IP_PROTOCOLS_UDP : parse_udp;
	    default : accept; // If it's not tcp or udp just accept
    	}
    }

    state parse_tcp {
	pkt.extract(ig_hdr.tcp);
        transition accept;
    }
 
    state parse_udp {
	pkt.extract(ig_hdr.udp);
        transition accept;
    }
    
};

// No forwarding table being applied (just tetsing) and no actions are being executed
control MyIngress(
    inout headers_t ig_hdr,
    inout metadata_t ig_md,
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
    inout headers_t ig_hdr,
    in metadata_t ig_md,
    in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md)
{
    apply {
    }
};

// Again, no headers are extracted, just passing to acceptt
parser MyEgressParser(
    packet_in pkt,
    out headers_t eg_hdr,
    out metadata_t eg_md,
    out egress_intrinsic_metadata_t eg_intr_md)
{
    state start {
        transition accept;
    }
};

// Doesn't write anything in the headers
control MyEgress(
    inout headers_t eg_hdr,
    inout metadata_t eg_md,
    in egress_intrinsic_metadata_t eg_intr_md,
    in egress_intrinsic_metadata_from_parser_t eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t eg_oport_md,
    inout egress_intrinsic_metadata_for_lookback_t eg_lkup_md)
{
    apply {
    }
};

// DOESN'T FORWARD THE PACKAGE THROUGHOUT AN EXIT PORT (JUST TESTING)
control MyEgressDeparser(
    packet_out pkt,
    inout headers_t eg_hdr,
    in metadata_t eg_md,
    in egress_intrinsic_metadata_for_deparser_t eg_dprsr_md)
{
    apply {
    }
};

// defines the processing flow
Tofino2NativeArchitecture(
    MyIngressParser(),
    MyIngress(),
    MyIngressDeparser(),
    MyEgressParser(),
    MyEgress(),
    MyEgressDeparser()) pipe;

Switch(pipe) main;
