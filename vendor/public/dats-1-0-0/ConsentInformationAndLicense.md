### Proposed solution for dealing with Consent Information, Licenses and their relationship

This document describes the proposed changes to the DATS schemas to deal with the
description of consent information and how this impacts in the license information.

#### Creation of a consent_info_schema.json 

The proposal is to create a new entity for encapsulating the consent information associated
with entities in a dataset, such as a subject (represented with an object compliant with the
material_schema.json) and a study group (e.g. to indicate a dbGAP consent group).

Thus, it is possible to represent the consent information for patients and for groups of patients.

The consent information points to the derived license, which contains information about data use conditions.

This solution is an alternative of including the consent information directly in the license, 
following a separation of concerns between consent and data use conditions. 

The relationship between material and study groups to the license comes through the consent information.

#### Extension of the license_schema.json:

The license schema is extended with the data use conditions. The directionality of 
