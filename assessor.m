% Machine Learning Homework 2
% Mohammad Maghsoudi Mehrabani - 810895019

% run: assessor(0) - evaluating test_houses
%    or
% run: assessor(1) - leave one out testing

function assessor(testing)
%function assessor(testing) implements CBR system
%where input is:
%testing - 0 - evaluating test_houses, 1 - leave one out testing

fprintf(1,'working\n');

load house_database.dat;
load test_houses.dat;
leave_one_out_testing = testing;	% if you are doing leave one out testing (0 - no, 1 - yes)
k = 4; 					% find 4 closest cases
dimensions = 7;                 	% number of attributes in a houses description
total_estimate_error = 0;		% used for leave one out testing


labeled_cases=house_database;
if leave_one_out_testing == 0
   input=test_houses;
   steps = 1;
else
   input=house_database;
   steps = 33;
   fprintf(1,'lat \tlong \tlot \tliving\tbed \tbath \tquality\tprice \test. \terror\n');
end

for n=1:steps:length(input(:,1));
   i=1;
   knn_set=[];

   while (i < length(labeled_cases(:,1))),
      %compute distance from input to all labeled cases

      %
      % TO DO: modify statement below to take all attributes into consideration.
      %        create a function to do this. 
      %

      
           	 	 		 	 	
     candidate_dist=...
                    ...6.5*(abs(input(n,1)-labeled_cases(i,1))^2 + abs(input(n,2)-labeled_cases(i,2))^2)...
                    67*(abs(input(n,1)-labeled_cases(i,1)) + abs(input(n,2)-labeled_cases(i,2)))...  lat/long  
                    +(abs(input(n,3)-labeled_cases(i,3)))^(5/6)...lot
                    +7*(abs(input(n,4)-labeled_cases(i,4)))...living
                    +400*(abs(input(n,5)-labeled_cases(i,5)))...bed
                    +770*(abs(input(n,6)-labeled_cases(i,6)))...bath
                    +850*(abs(input(n,7)-labeled_cases(i,7))); %quality

      % if the test case is the house being evaluated then disregard it
      if leave_one_out_testing == 1 && (input(n,1) == labeled_cases(i,1)) && (input(n,2) == labeled_cases(i,2))
	candidate_dist = 100000;
      end
  
      if  (i <= k)
         %include input in set of knn
         knn_set=[knn_set;[labeled_cases(i,:),candidate_dist]];
      elseif (candidate_dist <= min(knn_set(:,dimensions+2)) || max(knn_set(:,dimensions+2)) > candidate_dist)
         %if distance of candidate to labeled case is smaller than the previous nearest neighbor
         % then replace farthest of knn with input
         max_neighbor_dist = max(knn_set(:,dimensions+2));
         replaced_flag = 0; 
         for j=1:k
            if knn_set(j,dimensions+2)==max_neighbor_dist && replaced_flag == 0
	       replaced_flag = 1;
               knn_set(j,:)=[labeled_cases(i,:),candidate_dist];
            end
         end
      end
      i=i+1;
   end

   %
   % TO DO: adapt the value of the cases based on difference from test case
   %        an example adjustment for bedrooms is given below
   %

   adapted_knn_set = knn_set;
   for i = 1:k

        lat_adjust = 1150 * (input(n,1) - adapted_knn_set(i,1));
        long_adjust = 1150 * (input(n,2) - adapted_knn_set(i,2));
        lot_adjust =  (input(n,3) - adapted_knn_set(i,3));
        living_adjust = 63 * (input(n,4) - adapted_knn_set(i,4));
        bed_adjust = 1800 * (input(n,5) - adapted_knn_set(i,5));
        bath_adjust = 5000 * (input(n,6) - adapted_knn_set(i,6));
        quality_adjust = 30210 * (input(n,7) - adapted_knn_set(i,7));
        
        adapted_knn_set(i,8) = adapted_knn_set(i,8) ...
            + bed_adjust + quality_adjust+living_adjust ...
            + lat_adjust+long_adjust + lot_adjust + bath_adjust;
   end

 
   %
   % TO DO: aggregate the values of the cases to get a single value for the test house
   %

   
    estimated_value = 0 ;% round(sum(adapted_knn_set(:,dimensions + 1)) / k);
      divider = 0;
        for i=1:k
            price_factor = (1/(adapted_knn_set(i,dimensions + 2)+1));
            estimated_value=...
                estimated_value + price_factor * adapted_knn_set(i,dimensions + 1);
            divider = divider + price_factor;
        end
        
        estimated_value=round(estimated_value/divider);
   %
   % Extra Credit TO DO: determine your confidence in the estimate
   %

    score=1;
    
    confidence = cell(3,1);
    confidence{1} = 'Low';
    confidence{2} = 'Medium';
    confidence{3} = 'High';
   
     for i=1:k
         %breakPoint1 = abs(adapted_knn_set(i,dimensions + 1) - estimated_value);
         %breakPoint2 = adapted_knn_set(i,dimensions + 2);
        if abs(adapted_knn_set(i,dimensions + 1) - estimated_value ) < 6000 && adapted_knn_set(i,dimensions + 2) < 1250
            score=score+1;
        end    
     end
      
     %convert score range to confidence range : 1 or 2 or 3 
      confidence_Result = round(((score - 1) / (k+1 - 1)) * (3 - 1) + 1);

   if leave_one_out_testing == 0 

     fprintf(1,'TEST HOUSE %d\n', n);
     fprintf(1,'lat \tlong \tlot \tliving\tbed \tbath \tquality\n');
     fprintf(1,'%d\t%d\t%d\t%d\t%d\t%3.1f\t%d\n',input(n,:));


     % show the non-adapted set of cases
     fprintf(1,'\n\nNON-ADAPTED CASES\n');
     fprintf(1,'lat \tlong \tlot \tliving\tbed \tbath \tquality\tvalue \tsimilarity\n');
     for i = 1:k
       fprintf(1,'%d\t%d\t%d\t%d\t%d\t%3.1f\t%d\t%d\t%d\n',knn_set(i,:));
     end

     % show the adapted set of cases
     fprintf(1,'\nADAPTED CASES\n');
     fprintf(1,'lat \tlong \tlot \tliving\tbed \tbath \tquality\tvalue \tsimilarity\n');
     for i = 1:k
       fprintf(1,'%d\t%d\t%d\t%d\t%d\t%3.1f\t%d\t%d\t%d\n',adapted_knn_set(i,:));
     end

     % print out the estimated value
     fprintf(1,'\nESTIMATED VALUE = %d\n', estimated_value); 

     fprintf(1,'CONFIDENCE IS %s\n\n\n', confidence{confidence_Result}); 

   else      % leave_one_out_testing == 1 

      fprintf(1,'%d\t%d\t%d\t%d\t%d\t%3.1f\t%d\t%d\t',input(n,:));
      estimate = round(sum(adapted_knn_set(:,dimensions + 1)) / k);
      estimate_error = abs(estimate - input(n,8));
      fprintf(1,'%d\t%d', estimate, estimate_error); 
      fprintf(1,'\n'); 
      total_estimate_error = total_estimate_error + estimate_error;
   end

end

if leave_one_out_testing == 1 
   fprintf(1,'average error = %d\n', total_estimate_error / (length(input(:,1)) / steps));
end
