/***************************************************************
 *
 * Copyright (C) 1990-2012, Condor Team, Computer Sciences Department,
 * University of Wisconsin-Madison, WI.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License.  You may
 * obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ***************************************************************/


#include "condor_common.h"
#include "condor_attributes.h"
#include "string_list.h"

#include "consumption_policy.h"


void assign_preserve_integers(ClassAd& ad, const char* attr, double v) {
    if ((v - floor(v)) > 0.0) {
        ad.Assign(attr, v);
    } else {
        ad.Assign(attr, (long long)(v));
    }
}


bool cp_supports_policy(ClassAd& resource, bool strict) {
    // currently, only p-slots can support a functional consumption policy
    if (strict) {
        bool part = false;
        if (!resource.LookupBool(ATTR_SLOT_PARTITIONABLE, part)) part = false;
        if (!part) return false;
    }

    // must support MachineResources attribute
    string mrv;
    if (!resource.LookupString(ATTR_MACHINE_RESOURCES, mrv)) return false;

    // must define ConsumptionXxx for all resources Xxx (including extensible resources)
    StringList alist(mrv.c_str());
    alist.rewind();
    while (char* asset = alist.next()) {
        if (0 == strcmp(asset, "swap")) continue;
        string ca;
        formatstr(ca, "%s%s", ATTR_CONSUMPTION_PREFIX, asset);
        ClassAd::iterator f(resource.find(ca));
        if (f == resource.end()) return false;
    }

    return true;
}


void cp_compute_consumption(ClassAd& job, ClassAd& resource, map<string, double>& consumption) {
    consumption.clear();

    string mrv;
    if (!resource.LookupString(ATTR_MACHINE_RESOURCES, mrv)) {
        EXCEPT("Resource ad missing %s attribute", ATTR_MACHINE_RESOURCES);
    }

    StringList alist(mrv.c_str());
    alist.rewind();
    while (char* asset = alist.next()) {
        if (0 == strcmp(asset, "swap")) continue;

        string ra;
        string coa;
        formatstr(ra, "%s%s", ATTR_REQUEST_PREFIX, asset);
        formatstr(coa, "_condor_%s", ra.c_str());
        bool override = false;
        double ov=0;
        if (job.EvalFloat(coa.c_str(), NULL, ov)) {
            // Allow _condor_RequestedXXX to override RequestedXXX
            // this case is intended to be operative when a scheduler has set 
            // such values and sent them on to the startd that owns this resource
            // (e.g. I'd not expect this case to arise elsewhere, like the negotiator)
            string ta;
            formatstr(ta, "_cp_temp_%s", ra.c_str());
            job.CopyAttribute(ta.c_str(), ra.c_str());
            job.Assign(ra.c_str(), ov);
            override = true;
        }

        // get the requested asset value
        bool missing = false;
        ClassAd::iterator f(job.find(ra));
        if (f == resource.end()) {
            // a RequestXxx attribute not present - default to zero
            job.Assign(ra.c_str(), 0);
            missing = true;
        }

        // compute the consumed value for the asset
        string ca;
        formatstr(ca, "%s%s", ATTR_CONSUMPTION_PREFIX, asset);
        double cv = 0;
        if (!resource.EvalFloat(ca.c_str(), &job, cv)) {
            EXCEPT("Evaluation of %s attribute failed", ca.c_str());
        }
        consumption[asset] = cv;

        if (override) {
            // restore saved value for RequestedXXX if it was overridden by _condor_RequestedXXX
            string ta;
            formatstr(ta, "_cp_temp_%s", ra.c_str());
            job.CopyAttribute(ra.c_str(), ta.c_str());
            job.Delete(ta.c_str());
        }
        if (missing) {
            // remove temporary attribute to restore original state
            job.Delete(ra.c_str());
        }
    }
}


bool cp_sufficient_assets(ClassAd& job, ClassAd& resource) {
    map<string, double> consumption;
    cp_compute_consumption(job, resource, consumption);
    return cp_sufficient_assets(resource, consumption);
}


bool cp_sufficient_assets(ClassAd& resource, const map<string, double>& consumption) {
    for (map<string, double>::const_iterator j(consumption.begin());  j != consumption.end();  ++j) {
        const char* asset = j->first.c_str();
        double av=0;
        if (!resource.LookupFloat(asset, av)) {
            EXCEPT("Missing %s resource asset", asset);
        }
        if (av < j->second) {
            return false;
        }
    }
    return true;
}


double cp_deduct_assets(ClassAd& job, ClassAd& resource, bool test) {
    map<string, double> consumption;
    cp_compute_consumption(job, resource, consumption);

    // slot weight before asset deductions
    double w0 = 0;
    if (!resource.EvalFloat(ATTR_SLOT_WEIGHT, NULL, w0)) {
        EXCEPT("Failed to evaluate %s", ATTR_SLOT_WEIGHT);
    }

    // deduct consumption from the resource assets
    for (map<string, double>::iterator j(consumption.begin());  j != consumption.end();  ++j) {
        const char* asset = j->first.c_str();
        double av=0;
        if (!resource.LookupFloat(asset, av)) {
            EXCEPT("Missing %s resource asset", asset);
        }
        assign_preserve_integers(resource, asset, av - j->second);
    }

    // slot weight after deductions
    double w1 = 0;
    if (!resource.EvalFloat(ATTR_SLOT_WEIGHT, NULL, w1)) {
        EXCEPT("Failed to evaluate %s", ATTR_SLOT_WEIGHT);
    }

    // define cost as difference in slot weight before and after asset deduction
    double cost = w0 - w1;

    // if we are not in testing mode, then keep the asset deductions
    if (!test) return cost;

    // The Dude just wants his assets back
    for (map<string, double>::iterator j(consumption.begin());  j != consumption.end();  ++j) {
        const char* asset = j->first.c_str();
        double av=0;
        resource.LookupFloat(asset, av);
        assign_preserve_integers(resource, asset, av + j->second);
    }

    return cost;
}


void cp_override_requested(ClassAd& job, ClassAd& resource, map<string, double>& consumption) {
    cp_compute_consumption(job, resource, consumption);

    for (map<string, double>::iterator j(consumption.begin());  j != consumption.end();  ++j) {
        const char* asset = j->first.c_str();
        string ra;
        string oa;
        formatstr(ra, "%s%s", ATTR_REQUEST_PREFIX, asset);
        formatstr(oa, "_cp_orig_%s%s", ATTR_REQUEST_PREFIX, asset);
        job.CopyAttribute(oa.c_str(), ra.c_str());
        assign_preserve_integers(job, ra.c_str(), j->second);
    }
}


void cp_restore_requested(ClassAd& job, const map<string, double>& consumption) {
    for (map<string, double>::const_iterator j(consumption.begin());  j != consumption.end();  ++j) {
        const char* asset = j->first.c_str();
        string ra;
        string oa;
        formatstr(ra, "%s%s", ATTR_REQUEST_PREFIX, asset);
        formatstr(oa, "_cp_orig_%s%s", ATTR_REQUEST_PREFIX, asset);
        job.CopyAttribute(ra.c_str(), oa.c_str());
        job.Delete(oa);
    }    
}
